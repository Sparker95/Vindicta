#include "common.hpp"

/*
Class: ActionGroup.ActionGroupGetInVehiclesAsCrew
All members of this group will mount all vehicles in this group.

Parameter tags:
"onlyCombat" - optional, default false. if true, units will occupy only combat vehicles.
*/

#define pr private

CLASS("ActionGroupGetInVehiclesAsCrew", "ActionGroup")

	VARIABLE("driversAI");
	VARIABLE("turretsAI");
	VARIABLE("onlyCombat");

	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		pr _onlyCombat = CALLSM3("Action", "getParameterValue", _parameters, "onlyCombat", false);
		T_SETV("onlyCombat", _onlyCombat);

		T_SETV("driversAI", []);
		T_SETV("turretsAI", []);
	} ENDMETHOD;

	// Helper function to determine the best applicant for a crew position (the unit already occupying the position, or the closest one)
	STATIC_METHOD("_getPreferredCrew") {
		params [P_THISCLASS, P_ARRAY("_crewAIArray"), P_OOP_OBJECT("_vehicle"), P_STRING("_vehicleRole"), P_ARRAY("_turretPath")];

		pr _hVeh = CALLM0(_vehicle, "getObjectHandle");
		pr _vehCrew = fullCrew _hVeh;
		// Sort crewAI by match with current position, then distance to vehicle
		pr _sortableCrewAI = _crewAIArray apply {
			pr _crewAI = _x;
			pr _hCrew = GETV(_crewAI, "hO");
			pr _currPosIdx =  _vehCrew findIf { _x#0 == _hCrew };
			pr _currPos = if(_currPosIdx == NOT_FOUND) then { [objNull, "", -1, [], false] } else { _vehCrew#_currPosIdx };
			_currPos params ["_unit", "_role", "_cargoIndex", "_turretPath", "_personTurret"];
			pr _assignedRole = assignedVehicleRole _hCrew;
			[
				// Suitability score
					// Unit is already crew of the same vehicle
					([0, 2] select (_unit == _hCrew)) * (
						// Unit is already assigned to the correct role
						([0, 1] select (_role == _vehicleRole && {_vehicleRole == "DRIVER" || { _vehicleRole == "TURRET" && _turretPath == _turretPath } })) +
						1
					)
					// Distance factor (never overrides the same-vehicle score above)
					+ 1 / (1 + (_hCrew distance2D _hVeh)),
				_crewAI
			]
		};
		// Higher score is better
		_sortableCrewAI sort DESCENDING;
		// Return the best
		_sortableCrewAI#0#1
	} ENDMETHOD;

	// logic to run when the goal is activated
	// _unitsIgnore - units to ignore in assignment. For instance if this unit was destroyed.
	METHOD("activate") {
		params [P_THISOBJECT, P_BOOL("_instant")];
		OOP_INFO_0("ACTIVATE");
		T_CALLM2("_activateImpl", [], _instant);
	} ENDMETHOD;

	METHOD("_activateImpl") {
		params [P_THISOBJECT, P_ARRAY("_unitsIgnore"), P_BOOL("_instant")];
		
		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");
		pr _onlyCombat = T_GETV("onlyCombat");
		
		// Assign units to vehicles
		pr _units = CALLM0(_group, "getUnits") - _unitsIgnore;
		pr _vehicles = (_units select {CALLM0(_x, "isVehicle")}) - _unitsIgnore; // _unitsIgnore can also contain vehicles

		if(count _vehicles == 0) exitWith {
			OOP_WARNING_2("Group %1 does not contain any vehicles (units = %2), so ActionGroupGetInVehiclesAsCrew makes no sense", _group, _units);
			T_SETV("state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED
		};

		if(_onlyCombat) then {
			_vehicles = _vehicles select {
				CALLM0(_x, "getSubcategory") in T_VEH_combat
			};
		};

		// Array with standard crew for each vehicle
		pr _vehiclesStdCrew = _vehicles apply {
			[_x] + ([CALLM0(_x, "getClassName")] call misc_fnc_getFullCrew);
		};
		pr _crewAI = _units select { CALLM0(_x, "isInfantry") } apply { CALLM0(_x, "getAI") };

		if(count _crewAI == 0) then {
			OOP_WARNING_2("Group %1 does not contain any crew units (units = %2), so ActionGroupGetInVehiclesAsCrew can't be done", _group, _units);
		};

		// Delete previous goals of units to get into vehicles
		{
			CALLM2(_x, "deleteExternalGoal", "GoalUnitGetInVehicle", "");
		} forEach _crewAI;

		// Try to assign drivers
		pr _driversAI = [];

		{// forEach _vehiclesStdCrew;
			_x params ["_vehicle", "_n_driver", "_copilotTurrets", "_stdTurrets", "_psgTurrets", "_n_cargo"];
			if (_n_driver > 0 && count _crewAI > 0) then {
				// Find best crew to fill the position
				pr _driverAI = CALLSM3("ActionGroupGetInVehiclesAsCrew", "_getPreferredCrew", _crewAI, _vehicle, "DRIVER");
				_crewAI deleteAt (_crewAI find _driverAI);

				// Add goal to this driver
				pr _parameters = [
					["vehicle", _vehicle],
					["vehicleRole", "DRIVER"],
					[TAG_INSTANT, _instant]
				];
				CALLM4(_driverAI, "addExternalGoal", "GoalUnitGetInVehicle", 0, _parameters, _AI);

				// Add the AI of this driver to the array
				_driversAI pushBack _driverAI;
			};
		} forEach _vehiclesStdCrew;
		
		// Try to assign standard turrets
		pr _turretsAI = [];

		{// forEach _vehiclesStdCrew
			_x params ["_vehicle", "_n_driver", "_copilotTurrets", "_stdTurrets", "_psgTurrets", "_n_cargo"];
			{
				pr _turretPath = _x;
				if (count _crewAI > 0) then {
					// Find best crew to fill the position
					pr _turretAI = CALLSM4("ActionGroupGetInVehiclesAsCrew", "_getPreferredCrew", _crewAI, _vehicle, "TURRET", _turretPath);
					_crewAI deleteAt (_crewAI find _turretAI);

					// Add goal to this turret
					pr _parameters = [
						["vehicle", _vehicle],
						["vehicleRole", "TURRET"],
						["turretPath", _turretPath],
						[TAG_INSTANT, _instant]
					];
					CALLM4(_turretAI, "addExternalGoal", "GoalUnitGetInVehicle", 0, _parameters, _AI);

					_turretsAI pushback _turretAI;
				};
			} forEach _stdTurrets;
		} forEach _vehiclesStdCrew;

		// Assign regroup goal to remaining inf

		pr _parameters = [[TAG_INSTANT, _instant]];
		{
			CALLM4(_x, "addExternalGoal", "GoalUnitInfantryRegroup", 0, _parameters, _AI);
		} forEach _crewAI;
		
		T_SETV("driversAI", _driversAI);
		T_SETV("turretsAI", _turretsAI);
		
		pr _state = if(count _driversAI == 0 && count _turretsAI == 0) then {
			// If no drivers or turrets are required then we succeeded immediately
			ACTION_STATE_COMPLETED
		} else {
			ACTION_STATE_ACTIVE
		};
		
		// Return ACTIVE state
		T_SETV("state", _state);
		_state
	} ENDMETHOD;
	
	// Logic to run each update-step
	METHOD("process") {
		params [P_THISOBJECT];
		
		T_CALLM0("failIfNoInfantry");
		
		pr _state = T_CALLM0("activateIfInactive");
		
		OOP_INFO_1("Process: state: %1", _state);
		
		if (_state == ACTION_STATE_ACTIVE) then {
			
			// Wait until all given goals are completed
			pr _AI = T_GETV("AI");
			pr _group = GETV(_AI, "agent");
			pr _groupUnits = CALLM0(_group, "getInfantryUnits");

			if (CALLSM3("AI_GOAP", "allAgentsCompletedExternalGoal", _groupUnits, "GoalUnitGetInVehicle", "")
				|| !CALLSM3("AI_GOAP", "anyAgentHasExternalGoal", _groupUnits, "GoalUnitGetInVehicle", "")) then {
				//pr _ws = GETV(_AI, "worldState");
				//if ([_ws, WSP_GROUP_ALL_INFANTRY_MOUNTED] call ws_getPropertyValue) then {
				OOP_INFO_0("Action COMPLETED");
				
				// Update sensors
				CALLM0(GETV(T_GETV("AI"), "sensorHealth"), "update");
				
				// We are done here
				T_SETV("state", ACTION_STATE_COMPLETED);
				ACTION_STATE_COMPLETED
			} else {
				// Fail this action if any unit has failed
				if (CALLSM3("AI_GOAP", "anyAgentFailedExternalGoal", _groupUnits, "GoalUnitGetInVehicle", "")) then {
					OOP_INFO_0("Crew mount action is failed. Some crew could not mount...");
					ACTION_STATE_FAILED
				} else {
					OOP_INFO_0("Crew mount action is active. Not all crew is in their vehicles...");
					ACTION_STATE_ACTIVE
				};
			};
			
		} else {
			_state
		};
	} ENDMETHOD;
	
	METHOD("handleUnitsRemoved") {
		params [P_THISOBJECT, P_ARRAY("_units")];

		OOP_INFO_1("Units removed: %1", _units);

		// Call activate method, pass the unit that was removed
		T_CALLM1("_activateImpl", _units);

		/*
		pr _state = T_GETV("state");
		if (_state == ACTION_STATE_ACTIVE || _state == ACTION_STATE_COMPLETED) then {
			// At next process call activate once again to assign the units
			T_SETV("state", ACTION_STATE_INACTIVE);
		};
		*/
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [P_THISOBJECT];
		
		// Delete given goals
		pr _group = GETV(T_GETV("AI"), "agent");
		pr _crew = CALLM0(_group, "getInfantryUnits");
		
		// Delete previous goals of units to get into vehicles
		{
			pr _crewAI = CALLM0(_x, "getAI");
			CALLM2(_crewAI, "deleteExternalGoal", "GoalUnitGetInVehicle", "");
			CALLM2(_crewAI, "deleteExternalGoal", "GoalUnitInfantryRegroup", "");
		} forEach _crew;
		
	} ENDMETHOD;

ENDCLASS;


/*
_unit = cursorObject; 
_goalClassName = "GoalGroupGetInVehiclesAsCrew"; 
_parameters = []; 
call compile preprocessFileLineNumbers "AI\Misc\testFunctions.sqf";
[_unit, _goalClassName, _parameters] call AI_misc_fnc_addGroupGoal;
*/
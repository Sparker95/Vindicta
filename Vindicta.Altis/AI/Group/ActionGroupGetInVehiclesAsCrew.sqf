#include "common.hpp"

/*
Class: ActionGroup.ActionGroupGetInVehiclesAsCrew
All members of this group will mount all vehicles in this group.

Parameter tags:
"onlyCombat" - optional, default false. if true, units will occupy only combat vehicles.
*/

#define pr private

CLASS("ActionGroupGetInVehiclesAsCrew", "ActionGroup")

	VARIABLE("activeUnits");
	VARIABLE("onlyCombat");

	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		pr _onlyCombat = CALLSM3("Action", "getParameterValue", _parameters, "onlyCombat", false);
		T_SETV("onlyCombat", _onlyCombat);

		T_SETV("activeUnits", []);
	} ENDMETHOD;

	// Helper function to determine the best applicant for a crew position (the unit already occupying the position, or the closest one)
	STATIC_METHOD("_getPreferredCrew") {
		params [P_THISCLASS, P_ARRAY("_crewAIArray"), P_OOP_OBJECT("_vehicle"), P_STRING("_role"), P_ARRAY("_turretPath")];

		pr _hVeh = CALLM0(_vehicle, "getObjectHandle");
		//pr _vehCrew = fullCrew _hVeh;
		// Sort crewAI by match with current position, then distance to vehicle
		pr _sortableCrewAI = _crewAIArray apply {
			pr _crewAI = _x;
			pr _crewhO = GETV(_crewAI, "hO");
			pr _assignedVehicle = CALLM0(_crewAI, "getAssignedVehicle");
			pr _score = 1 / (1 + (_crewhO distance2D _hVeh));
			if(_assignedVehicle == _vehicle) then { 
				_score = _score + 16;
				if(CALLM0(_crewAI, "getAssignedVehicleRole") == _role) then {
					_score = _score + 8;
					if(_role == "TURRET" && {GETV(_crewAI, "assignedTurretPath") isEqualTo _turretPath}) then {
						_score = _score + 4;
					};
				};
			};
			[_score, _crewAI]

			// pr _hCrew = GETV(_availableCrewAI, "hO");
			// pr _currPosIdx =  _vehCrew findIf { _x#0 == _hCrew };
			// pr _currPos = if(_currPosIdx == NOT_FOUND) then { [objNull, "", -1, [], false] } else { _vehCrew#_currPosIdx };
			// _currPos params ["_assignedUnit", "_assignedRole", "_assignedCargoIndex", "_assignedTurretPath", "_assignedPersonTurret"];
			// //pr _assignedRole = assignedVehicleRole _hCrew;
			// [
			// 	// Suitability score
			// 		// Unit is already crew of the same vehicle
			// 		([0, 2] select (_assignedUnit isEqualTo _hCrew)) * (
			// 			// Unit is already assigned to the correct role
			// 			([0, 1] select (_assignedRole == _role && {_role == "DRIVER" || { _role == "TURRET" && _turretPath isEqualTo _assignedTurretPath } })) +
			// 			1
			// 		)
			// 		// Distance factor (never overrides the same-vehicle score above)
			// 		+ 1 / (1 + (_hCrew distance2D _hVeh)),
			// 	_availableCrewAI
			// ]
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

		T_CALLM0("clearUnitGoals");
		T_CALLM0("regroup");

		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");
		pr _onlyCombat = T_GETV("onlyCombat");
		
		pr _units = CALLM0(_group, "getUnits");
		pr _vehicles = _units select {CALLM0(_x, "isVehicle")};

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
		pr _availableCrewAI = _units select { CALLM0(_x, "isInfantry") } apply { CALLM0(_x, "getAI") };

		if(count _availableCrewAI == 0) then {
			OOP_WARNING_2("Group %1 does not contain any crew units (units = %2), so ActionGroupGetInVehiclesAsCrew can't be done", _group, _units);
		};

		// Try to assign drivers
		pr _driversAI = [];

		{// forEach _vehiclesStdCrew;
			_x params ["_vehicle", "_n_driver", "_copilotTurrets", "_stdTurrets", "_psgTurrets", "_n_cargo"];
			if (_n_driver > 0 && count _availableCrewAI > 0) then {
				// Find best crew to fill the position
				pr _driverAI = CALLSM3("ActionGroupGetInVehiclesAsCrew", "_getPreferredCrew", _availableCrewAI, _vehicle, "DRIVER");
				_availableCrewAI deleteAt (_availableCrewAI find _driverAI);

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
				if (count _availableCrewAI > 0) then {
					// Find best crew to fill the position
					pr _turretAI = CALLSM4("ActionGroupGetInVehiclesAsCrew", "_getPreferredCrew", _availableCrewAI, _vehicle, "TURRET", _turretPath);
					_availableCrewAI deleteAt (_availableCrewAI find _turretAI);

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
			//CALLM0(_x, "unassignVehicle");
			CALLM4(_x, "addExternalGoal", "GoalUnitInfantryRegroup", 0, _parameters, _AI);
		} forEach _availableCrewAI;
		
		pr _activeUnits = (_driversAI + _turretsAI) apply { GETV(_x, "agent") };
		T_SETV("activeUnits", _activeUnits);
		
		pr _state = if(count _activeUnits == 0) then {
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
		
		if(T_CALLM0("failIfNoInfantry") == ACTION_STATE_FAILED) exitWith {
			ACTION_STATE_FAILED
		};
		
		pr _state = T_CALLM0("activateIfInactive");
		if (_state == ACTION_STATE_ACTIVE) then {
			// Wait until all given goals are completed
			pr _activeUnits = T_GETV("activeUnits");
			pr _AI = T_GETV("AI");
			if (CALLSM3("AI_GOAP", "allAgentsCompletedExternalGoalRequired", _activeUnits, "GoalUnitGetInVehicle", _AI)) then {
				// Update sensors immediately
				CALLM0(GETV(T_GETV("AI"), "sensorHealth"), "update");
				_state = ACTION_STATE_COMPLETED;
			} else {
				// Fail this action if any unit has failed
				_state = if (CALLSM3("AI_GOAP", "anyAgentFailedExternalGoal", _activeUnits, "GoalUnitGetInVehicle", _AI)) then {
					OOP_INFO_0("Crew mount action is failed. Some crew could not mount...");
					ACTION_STATE_FAILED
				} else {
					OOP_INFO_0("Crew mount action is active. Not all crew is in their vehicles...");
					ACTION_STATE_ACTIVE
				};
			};
		};

		T_SETV("state", _state);
		_state
	} ENDMETHOD;

	METHOD("handleUnitsRemoved") {
		params [P_THISOBJECT, P_ARRAY("_units")];
		T_SETV("state", ACTION_STATE_INACTIVE);
		
		// Remove the specified units from the active units list, their goals have already been removed by the AI
		private _activeUnits = T_GETV("activeUnits");
		{
			_activeUnits deleteAt (_activeUnits find _x);
		} forEach _units;
	} ENDMETHOD;

	METHOD("handleUnitsAdded") {
		params [P_THISOBJECT, P_ARRAY("_units")];
		T_SETV("state", ACTION_STATE_INACTIVE);
	} ENDMETHOD;

ENDCLASS;


/*
_unit = cursorObject;
_goalClassName = "GoalGroupGetInVehiclesAsCrew";
_parameters = [];
call compile preprocessFileLineNumbers "AI\Misc\testFunctions.sqf";
[_unit, _goalClassName, _parameters] call AI_misc_fnc_addGroupGoal;
*/
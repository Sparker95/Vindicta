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
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];
		
		pr _onlyCombat = CALLSM3("Action", "getParameterValue", _parameters, "onlyCombat", false);
		if (isNil "_onlyCombat") then {_onlyCombat = false;};
		T_SETV("onlyCombat", _onlyCombat);
		
		T_SETV("driversAI", []);
		T_SETV("turretsAI", []);
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	// _unitsIgnore - units to ignore in assignment. For instance if this unit was destroyed.
	METHOD("activate") {
		params [["_thisObject", "", [""]], ["_unitsIgnore", []]];
		
		OOP_INFO_0("ACTIVATE");
		
		pr _AI = T_GETV("AI");
		pr _group = GETV(T_GETV("AI"), "agent");
		pr _onlyCombat = T_GETV("onlyCombat");
		
		// Assign units to vehicles
		pr _units = CALLM0(_group, "getUnits") - _unitsIgnore;
		pr _vehicles = (_units select {CALLM0(_x, "isVehicle")}) - _unitsIgnore; // _unitsIgnore can also contain vehicles

		if(count _vehicles == 0) exitWith {
			OOP_ERROR_2("Group %1 does not contain any vehicles (units = %2), so ActionGroupGetInVehiclesAsCrew makes no sense", _group, _units);
			T_SETV("state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED
		};

		// Array with standard crew for each vehicle
		pr _vehiclesStdCrew = _vehicles apply {
			[CALLM0(_x, "getClassName")] call misc_fnc_getFullCrew;
		};
		pr _crew = _units select {CALLM0(_x, "isInfantry")};

		if(count _crew == 0) then {
			OOP_WARNING_2("Group %1 does not contain any crew units (units = %2), so ActionGroupGetInVehiclesAsCrew can't be done", _group, _units);
		};

		// Delete previous goals of units to get into vehicles
		{
			pr _crewAI = CALLM0(_x, "getAI");
			CALLM2(_crewAI, "deleteExternalGoal", "GoalUnitGetInVehicle", "");
		} forEach _crew;
		
		// Try to assign drivers
		pr _driversAI = [];
		for "_i" from 0 to ((count _vehicles) - 1) do {
			// Does this vehicle have a driver?
			(_vehiclesStdCrew select _i) params ["_n_driver", "_copilotTurrets", "_stdTurrets", "_psgTurrets", "_n_cargo"];
			if ((_n_driver > 0) && (count _crew > 0)) then {
				pr _newDriver = _crew select 0;
				pr _driverAI = CALLM0(_newDriver, "getAI");
				CALLM0(_vehicles select _i, "getMainData") params ["_catID", "_subcatID"];
				// If group must occupy only combat capable vehicles
				if ( !(_subcatID in T_VEH_combat) && _onlyCombat) then {
					CALLM4(_driverAI, "addExternalGoal", "GoalUnitInfantryRegroup", 0, [], _AI);
				} else {
					pr _parameters = [["vehicle", _vehicles select _i], ["vehicleRole", "DRIVER"], ["turretPath", 0]];
					// Add goal to this driver
					CALLM4(_driverAI, "addExternalGoal", "GoalUnitGetInVehicle", 0, _parameters, _AI);
				};
				
				
				// Add the AI of this driver to the array
				_driversAI pushBack _driverAI;
				
				// Don't assign this driver anywhere else
				_crew deleteat 0;
			};
		};
		
		// Try to assign standard turrets
		pr _turretsAI = [];
		for "_i" from 0 to ((count _vehicles) - 1) do {
			(_vehiclesStdCrew select _i) params ["_n_driver", "_copilotTurrets", "_stdTurrets", "_psgTurrets", "_n_cargo"];
			CALLM0(_vehicles select _i, "getMainData") params ["_catID", "_subcatID"];
			{
				if (count _crew > 0) then {
				
					pr _newTurret = _crew select 0;
					pr _turretAI = CALLM0(_newTurret, "getAI");
					if ( !(_subcatID in T_VEH_combat) && _onlyCombat) then {
						// If vehicle is not fight capable, just regroup near the leader
						CALLM4(_turretAI, "addExternalGoal", "GoalUnitInfantryRegroup", 0, [], _AI);
					} else {
						pr _turretPath = _x;
						pr _parameters = [["vehicle", _vehicles select _i], ["vehicleRole", "TURRET"], ["turretPath", _turretPath]];
						
						// Add goal to this turret
						CALLM4(_turretAI, "addExternalGoal", "GoalUnitGetInVehicle", 0, _parameters, _AI);
					};
					
					_turretsAI pushback _turretAI;
					
					_crew deleteAt 0;
				};
			} forEach _stdTurrets;
		};
		
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
		params [["_thisObject", "", [""]]];
		
		CALLM0(_thisObject, "failIfNoInfantry");
		
		pr _state = CALLM0(_thisObject, "activateIfInactive");
		
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
		params [["_thisObject", "", [""]], ["_units", [], [[]]] ];
		OOP_INFO_1("Units removed: %1", _units);
		
		// Call activate method, pass the unit that was removed
		CALLM1(_thisObject, "activate", _units);
		
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
		params [["_thisObject", "", [""]]];
		
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
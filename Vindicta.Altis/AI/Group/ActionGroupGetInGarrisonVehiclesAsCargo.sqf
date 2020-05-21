#include "common.hpp"

/*
Class: ActionGroupGetInGarrisonVehiclesAsCargo
All members of this group will mount all vehicles in this garrison as cargo.
*/

#define pr private

#define OOP_CLASS_NAME ActionGroupGetInGarrisonVehiclesAsCargo
CLASS("ActionGroupGetInGarrisonVehiclesAsCargo", "ActionGroup")

	VARIABLE("activeUnits");
	//VARIABLE("freeVehicles");
	VARIABLE("instantOverride");

	METHOD(new)
		params [P_THISOBJECT];
		
		T_SETV("activeUnits", []);
		T_SETV("instantOverride", false);
	ENDMETHOD;

	METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];

		// We need to save instant flag here as this action can need to reactivate multiple times to find a free seat
		_instant = T_GETV("instantOverride") || _instant;
		T_SETV("instantOverride", _instant);

		T_CALLM0("clearUnitGoals");
		T_CALLM0("regroup");

		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");

		// Get all infantry that aren't already in assigned vehicles
		pr _unitsInf = CALLM0(_group, "getInfantryUnits") select {
			pr _unitAI = CALLM0(_x, "getAI");
			// Not assigned to cargo, or not in assigned cargo spot
			CALLM0(_unitAI, "getAssignedVehicleRole") != "CARGO" || { !CALLM0(_unitAI, "isAtAssignedSeat") }
		};

		// Succeed instantly if there are no infantry
		if (count _unitsInf == 0) exitWith {
			T_SETV("state", ACTION_STATE_COMPLETED);
			ACTION_STATE_COMPLETED
		};

		pr _gar = CALLM0(_group, "getGarrison");

		// Get array of all vehicles in the garrison that can carry cargo troops
		pr _unitsVeh = CALLM0(_gar, "getVehicleUnits") apply {
			pr _freeSeats = CALLM1(CALLM0(_x, "getAI"), "getFreeCargoSeats", _unitsInf);
			// pr _className = CALLM0(_x, "getClassName");
			// pr _cap = [_className] call misc_fnc_getCargoInfantryCapacity;
			// pr _unitAI = CALLM0(_x, "getAI");
			// pr _assignedCargo = GETV(_unitAI, "assignedCargo");
			// if(isNil "_assignedCargo") then { _assignedCargo = [] };
			// _cap - count _assignedCargo
			[0, count _freeSeats, CALLM0(_x, "getPos"), _x]
		} select {
			_x#1 > 0
		};

		// Fail if there are no vehicles with cargo infantry capacity
		if (count _unitsVeh == 0) exitWith {
			T_SETV("state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED
		};

		//T_SETV("freeVehicles", _unitsVeh);
		pr _activeUnits = [];
		while { count _unitsInf > 0 && count _unitsVeh > 0 } do {
			pr _unit = _unitsInf deleteAt 0;
			pr _unitPos = CALLM0(_unit, "getPos");

			// Sort by distance
			_unitsVeh = _unitsVeh apply {
				[_x#2 distance2D _unitPos, _x#1, _x#2, _x#3]
			};
			_unitsVeh sort ASCENDING;
			(_unitsVeh#0) params ["_dist", "_seats", "_vehPos", "_veh"];
			if(_seats == 1) then {
				_unitsVeh deleteAt 0;
			} else {
				(_unitsVeh#0) set [1, _seats - 1];
			};
			pr _unitAI = CALLM0(_unit, "getAI");
			pr _args = [
				["vehicle", _veh],
				["vehicleRole", "CARGO"],
				[TAG_INSTANT, _instant]
			];
			CALLM4(_unitAI, "addExternalGoal", "GoalUnitGetInVehicle", 0, _args, _AI);
			_activeUnits pushBack _unit;
			// pr _unitsToLoad = _unitsInf select [0, _seats];
			// {
			// 	pr _unitAI = CALLM0(_x, "getAI");
			// 	pr _args = [
			// 		["vehicle", _veh],
			// 		["vehicleRole", "CARGO"],
			// 		[TAG_INSTANT, _instant]
			// 	];
			// 	CALLM4(_unitAI, "addExternalGoal", "GoalUnitGetInVehicle", 0, _args, _AI);
			// 	_activeUnits pushBack _x;
			// } forEach _unitsToLoad;
			// _unitsInf = _unitsInf - _unitsToLoad;
		};
		T_SETV("activeUnits", _activeUnits);

		// Return ACTIVE state
		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE

	ENDMETHOD;

	METHOD(process)
		params [P_THISOBJECT];
		
		if(T_CALLM0("failIfNoInfantry") == ACTION_STATE_FAILED) exitWith {
			ACTION_STATE_FAILED
		};

		pr _state = T_CALLM0("activateIfInactive");

		if (_state == ACTION_STATE_ACTIVE) then {
			// if (CALLSM3("AI_GOAP", "allAgentsCompletedExternalGoalRequired", _unitsInf, "GoalUnitGetInVehicle", _AI)) then {
			// 	CALLM0(GETV(T_GETV("AI"), "sensorHealth"), "update");
			// 	_state = ACTION_STATE_COMPLETED;
			// };
			// pr _group = GETV(T_GETV("AI"), "agent");
			// pr _unitsInf = CALLM0(_group, "getInfantryUnits");
			// pr _nGoalsCompleted = 0;
			// pr _AI = T_GETV("AI");
			// pr _freeVehicles = T_GETV("freeVehicles");
			// {
			// 	pr _unitAI = CALLM0(_x, "getAI");
			// 	pr _goalState = CALLM2(_unitAI, "getExternalGoalActionState", "GoalUnitGetInVehicle", _AI);

			// 	switch (_goalState) do {
			// 		case ACTION_STATE_ACTIVE: {
			// 			// Probably nothing to do here...
			// 		};

			// 		case ACTION_STATE_COMPLETED: {
			// 			_nGoalsCompleted = _nGoalsCompleted + 1;
			// 		};

			// 		case ACTION_STATE_FAILED: {
			// 			// Get parameters passed to this goal
			// 			pr _parameters = CALLM2(_unitAI, "getExternalGoalParameters", "GoalUnitGetInVehicle", _AI);
			// 			pr _assignedVehicle = CALLSM2("Action", "getParameterValue", _parameters, "vehicle");
			// 			if (_assignedVehicle != NULL_OBJECT) then { // Just for safety

			// 				OOP_INFO_3("Unit failed to get into vehicle: %1, unit's AI: %2, parameters: %3", _x, _unitAI, _parameters);

			// 				// Delete this goal from the soldier
			// 				CALLM2(_unitAI, "deleteExternalGoal", "GoalUnitGetInVehicle", "");

			// 				// Choose another vehicle to get in
			// 				_freeVehicles pushBack (_freeVehicles deleteAt (_freeVehicles find _assignedVehicle));
			// 				pr _vehToGetIn = _freeVehicles select 0;

			// 				OOP_INFO_1("Added goal to get into another vehicle: %1", _vehToGetIn);

			// 				// Add a new goal to this unit
			// 				pr _args = [
			// 					["vehicle", _vehToGetIn],
			// 					["vehicleRole", "CARGO"]
			// 				];
			// 				CALLM4(_unitAI, "addExternalGoal", "GoalUnitGetInVehicle", 0, _args, _AI);
			// 			};
			// 		};
			// 	};
			// } forEach _unitsInf;
			pr _activeUnits = T_GETV("activeUnits");
			pr _AI = T_GETV("AI");
			if (CALLSM3("AI_GOAP", "allAgentsCompletedExternalGoalRequired", _activeUnits, "GoalUnitGetInVehicle", _AI)) exitWith {
				CALLM0(GETV(T_GETV("AI"), "sensorHealth"), "update");
				_state = ACTION_STATE_COMPLETED;
			};
			// If all units have completed or failed then reactivate
			if (CALLSM4("AI_GOAP", "allAgentsHaveExternalGoalState", _activeUnits, [ACTION_STATE_COMPLETED ARG ACTION_STATE_FAILED], "GoalUnitGetInVehicle", _AI)) exitWith {
				_state = ACTION_STATE_INACTIVE;
			};
		};

		T_SETV("state", _state);
		_state
	ENDMETHOD;

	METHOD(handleUnitsRemoved)
		params [P_THISOBJECT, P_ARRAY("_units")];
		T_SETV("state", ACTION_STATE_INACTIVE);

		// Remove the specified units from the active units list, their goals have already been removed by the AI
		private _activeUnits = T_GETV("activeUnits");
		{
			_activeUnits deleteAt (_activeUnits find _x);
		} forEach _units;
	ENDMETHOD;

	METHOD(handleUnitsAdded)
		params [P_THISOBJECT, P_ARRAY("_units") ];
		T_SETV("state", ACTION_STATE_INACTIVE);
	ENDMETHOD;

ENDCLASS;


/*
_unit = cursorObject;
_goalClassName = "GoalGroupGetInVehiclesAsCrew";
_parameters = [];
call compile preprocessFileLineNumbers "AI\Misc\testFunctions.sqf";
[_unit, _goalClassName, _parameters] call AI_misc_fnc_addGroupGoal;
*/
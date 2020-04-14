#include "common.hpp"

/*
Class: ActionGroup.ActionGroupRelax
*/

CLASS("ActionGroupRelax", "ActionGroup")

	VARIABLE("activeUnits");

	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI") ];
		T_SETV("activeUnits", []);
	} ENDMETHOD;

	// logic to run when the goal is activated
	METHOD("activate") {
		params [P_THISOBJECT, P_BOOL("_instant")];

		// Set behaviour
		T_CALLM2("applyGroupBehaviour", "DIAMOND", "SAFE");
		T_CALLM0("clearWaypoints");
		T_CALLM0("regroup");

		T_CALLM1("assignGoalsToFreeUnits", _instant);

		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);

		// Return ACTIVE state
		ACTION_STATE_ACTIVE

	} ENDMETHOD;

	// logic to run each update-step
	METHOD("process") {
		params [P_THISOBJECT];

		T_CALLM0("failIfEmpty");
		T_CALLM0("activateIfInactive");

		T_CALLM0("assignGoalsToFreeUnits");
		T_CALLM0("clearCompleteGoals");

		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
	} ENDMETHOD;

	METHOD("assignGoalsToFreeUnits") {
		params [P_THISOBJECT, P_BOOL("_instant")];

		private _group = T_GETV("group");
		private _activeUnits = T_GETV("activeUnits");
		private _loc = CALLM0(CALLM0(_group, "getGarrison"), "getLocation");
		private _units = CALLM0(_group, "getInfantryUnits");
		private _freeUnits = _units - (_activeUnits apply { _x#0 });

		if(count _freeUnits == 0) exitWith {};

		// Determine where we will look for relax activities
		private _posRad = if(_loc == NULL_OBJECT) then {
			[ CALLM0(_group, "getPos"), 250 ]
		} else {
			[ CALLM0(_loc, "getPos"), CALLM0(_loc, "getBoundingRadius") ]
		};
		_posRad params ["_pos", "_radius"];

		// Look for activities (these are defined by variables on objects)
		// TODO: use object classes as well
		private _objects = _pos nearObjects _radius;
		private _freeAmbient = _objects select {
			!isNil {_x getVariable "vin_defaultAnims"} 
			&& {!(_x getVariable ["vin_occupied", false])}
		} apply {
			[_x, "GoalUnitAmbientAnim"]
		};

		private _freeTargets = _objects select {
			!isNil {_x getVariable "vin_target_range"} 
			&& {!(_x getVariable ["vin_occupied", false])}
		} apply {
			[_x, "GoalUnitShootAtTargetRange"]
		};

		// Assign random activities to unoccupied units
		private _allActivities = (_freeAmbient + _freeTargets) call BIS_fnc_arrayShuffle;
		private _AI = T_GETV("AI");

		while { count _freeUnits > 0 && count _allActivities > 0 } do
		{
			private _unit = _freeUnits deleteAt 0;
			private _activity = _allActivities deleteAt 0;
			_activity params ["_object", "_goal"];
			_activeUnits pushBackUnique [_unit, _goal];
			private _parameters = [
				[TAG_TARGET, _object],
				[TAG_DURATION_SECONDS, selectRandom [5, 10, 20] * 60],
				[TAG_INSTANT, _instant]
			];
			private _unitAI = CALLM0(_unit, "getAI");
			CALLM4(_unitAI, "addExternalGoal", _goal, 0, _parameters, _AI);
		};
	} ENDMETHOD;

	METHOD("clearCompleteGoals") {
		params [P_THISOBJECT];
		private _activeUnits = T_GETV("activeUnits");
		private _AI = T_GETV("AI");
		{
			_x params ["_unit", "_goal"];
			if(!IS_OOP_OBJECT(_unit) || {!CALLM0(_unit, "isAlive")} || {CALLM0(_unit, "getAI") == NULL_OBJECT}) then {
				_activeUnits deleteAt (_activeUnits find _x);
			} else {
				private _unitAI = CALLM0(_unit, "getAI");
				private _unitGoalState = CALLM2(_unitAI, "getExternalGoalActionState", _goal, _AI);
				if(_unitGoalState in [ACTION_STATE_COMPLETED, ACTION_STATE_FAILED, ACTION_STATE_REPLAN]) then {
					CALLM2(_unitAI, "deleteExternalGoalRequired", _goal, _AI);
					_activeUnits deleteAt (_activeUnits find _x);
				};
			};
		} forEach (+_activeUnits);
		
	} ENDMETHOD;
	

ENDCLASS;
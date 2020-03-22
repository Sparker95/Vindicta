#include "common.hpp"

#define pr private

// Duration of this action
CLASS("ActionGarrisonClearArea", "ActionGarrisonBehaviour")

	VARIABLE("pos");
	VARIABLE("radius");
	VARIABLE("lastCombatDateNumber");
	VARIABLE("durationMinutes");

	// ------------ N E W ------------
	
	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
		pr _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		T_SETV("pos", _pos);

		pr _radius = CALLSM3("Action", "getParameterValue", _parameters, TAG_CLEAR_RADIUS, 100);
		T_SETV("radius", _radius);

		pr _durationSeconds = CALLSM3("Action", "getParameterValue", _parameters, TAG_DURATION_SECONDS, 30*60);
		pr _durationMinutes = ceil (_durationSeconds / 60); // Convert from seconds to minutes
		T_SETV("durationMinutes", _durationMinutes);

		T_SETV("lastCombatDateNumber", dateToNumber date);
		
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [P_THISOBJECT];
		
		OOP_INFO_0("ACTIVATE");
		

		//pr _pos = T_GETV("pos");
		T_PRVAR(AI);
		T_PRVAR(pos);
		T_PRVAR(radius);

		pr _gar = GETV(_AI, "agent");

		// Split vehicle groups
		CALLM0(_gar, "splitVehicleGroups");

		// Determine group size and type
		pr _groups = CALLM0(_gar, "getGroups") apply {
			[
				CALLM0(_x, "getType") in [GROUP_TYPE_VEH_NON_STATIC],
				_x
			]
		};
		// Inf groups sorted in strength from strongest to weakest (we will assign stronger ones on sweep)
		pr _infGroups = _groups select {
			!(_x#0)
		} apply {
			private _grp = _x#1;
			[
				count CALLM0(_grp, "getUnits"),
				_grp
			]
		};
		_infGroups sort DESCENDING;
		_infGroups = _infGroups apply {
			_x#1
		};

		// Vehicle groups sorted by strength from weakest to strongest (we will assign weaker ones on sweep)
		pr _vehGroups = _groups select {
			_x#0
		} apply {
			private _grp = _x#1;
			private _vics = CALLM0(_grp, "getVehicleUnits");
			private _totalEff = 0;
			{
				private _eff = CALLM0(_x, "getEfficiency");
				_totalEff = _totalEff + _eff#T_EFF_soft + _eff#T_EFF_medium * 4 + _eff#T_EFF_armor * 8;
			} forEach _vics;
			[
				_totalEff,
				_grp
			]
		};
		_vehGroups sort ASCENDING;
		_vehGroups = _vehGroups apply {
			_x#1
		};

		// We want to assign groups to appropriate tasks:
		//	inf/veh group to sweep
		//	inf/veh group to overwatch
		//	veh groups to overwatch
		//	inf groups to cover vehicles
		//	inf groups to sweep
		_fn_takeOne = {
			params["_prefer", "_fallback", "_target"];
			private _arr = [_prefer, _fallback] select (count _prefer == 0);
			if(count _arr > 0) then {
				_target pushBack (_arr deleteAt 0);
			};
		};

		pr _vehGroupsForInfAssignment = +_vehGroups;
		pr _vehGroupsOrig = +_vehGroups;

		pr _sweep = [];
		pr _overwatch = [];

		// // inf/veh group to sweep
		[_infGroups, _vehGroups, _sweep] call _fn_takeOne;
		// // inf/veh group to overwatch
		//[_vehGroups, _infGroups, _overwatch] call _fn_takeOne;

		// veh groups to overwatch
		_overwatch append _vehGroups;

		// inf groups to cover vehicles
		private _remainingInf = [];
		{
			_remainingInf append CALLM0(_x, "getInfantryUnits");
		} forEach _infGroups;

		while {count _remainingInf > 0 && count _vehGroupsForInfAssignment > 0} do {
			private _vehGroup = _vehGroupsForInfAssignment deleteAt 0;
			private _count = 0;
			while {_count < 4 && count _remainingInf > 0} do
			{
				private _inf = _remainingInf deleteAt 0;
				CALLM1(_vehGroup, "addUnit", _inf);
			};
		};
		_infGroups = _infGroups select { !CALLM0(_x, "isEmpty") };

		// inf groups to sweep
		_sweep append _infGroups;

		// Clean up
		CALLM0(_gar, "deleteEmptyGroups");

		private _commonTags = [
			[TAG_POS, _pos],
			[TAG_OVERWATCH_ELEVATION, 10],
			[TAG_BEHAVIOUR, "COMBAT"],
			[TAG_COMBAT_MODE, "RED"]
		];

		{// foreach _overwatch
			pr _groupAI = CALLM0(_x, "getAI");
			pr _args = if(_x in _vehGroupsOrig) then {
				[
					"GoalGroupVehicleOverwatchArea", 
					0, 
					[
						[TAG_OVERWATCH_GRADIENT, 0.4],
						[TAG_OVERWATCH_DISTANCE_MIN, MAXIMUM(300, _radius)],
						[TAG_OVERWATCH_DISTANCE_MAX, MAXIMUM(300, _radius) + 500]
					] + _commonTags,
					_AI
				]
			} else {
				[
					"GoalGroupInfantryOverwatchArea", 
					0, 
					[
						[TAG_OVERWATCH_GRADIENT, 50],
						[TAG_OVERWATCH_DISTANCE_MIN, MAXIMUM(300, _radius)],
						[TAG_OVERWATCH_DISTANCE_MAX, MAXIMUM(300, _radius) + 500]
					] + _commonTags,
					_AI
				]
			};
			CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);
		} forEach _overwatch;

		{// foreach _sweep
			pr _groupAI = CALLM0(_x, "getAI");
			pr _args = [
				"GoalGroupClearArea",
				0,
				[
					[TAG_POS, _pos],
					[TAG_CLEAR_RADIUS, _radius],
					[TAG_BEHAVIOUR, "COMBAT"],
					[TAG_COMBAT_MODE, "RED"]
				],
				_AI
			];
			CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);
		} forEach _sweep;

		// Set last combat date
		T_SETV("lastCombatDateNumber", dateToNumber date);

		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);

		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [P_THISOBJECT];
		
		pr _gar = T_GETV("gar");

		// Succeed after timeout if not spawned.
		if (!CALLM0(_gar, "isSpawned")) exitWith {

			pr _state = T_GETV("state");

			if (_state == ACTION_STATE_INACTIVE) then {
				// Set last combat date
				T_SETV("lastCombatDateNumber", dateToNumber date);
				_state = ACTION_STATE_ACTIVE;
			};

			pr _lastCombatDateNumber = T_GETV("lastCombatDateNumber");
			pr _dateNumberThreshold = dateToNumber [date#0,1,1,0, T_GETV("durationMinutes")];
			if (( (dateToNumber date) - _lastCombatDateNumber) > _dateNumberThreshold ) then {
				T_SETV("state", ACTION_STATE_COMPLETED);
				_state = ACTION_STATE_COMPLETED;
			} else {
				pr _timeLeft = numberToDate [date#0, _lastCombatDateNumber + _dateNumberThreshold - (dateToNumber date)];
				OOP_INFO_1("Clearing area, time left: %1", _timeLeft);
				_state = ACTION_STATE_ACTIVE;
			};

			T_SETV("state", _state);
			_state
		};

		pr _state = CALLM0(_thisObject, "activateIfInactive");
		if (_state == ACTION_STATE_ACTIVE) then {
			pr _AI = T_GETV("AI");
			
			// Check if we know about enemies
			pr _ws = GETV(_AI, "worldState");
			pr _awareOfEnemy = [_ws, WSP_GAR_AWARE_OF_ENEMY] call ws_getPropertyValue;
			
			if (_awareOfEnemy) then {
				T_SETV("lastCombatDateNumber", dateToNumber date); // Reset the timer

				T_CALLM0("attackEnemyBuildings"); // Attack buildings occupied by enemies
			} else {
				pr _lastCombatDateNumber = T_GETV("lastCombatDateNumber");
				pr _dateNumberThreshold = dateToNumber [date#0,1,1,0, T_GETV("durationMinutes")];
				if (( (dateToNumber date) - _lastCombatDateNumber) > _dateNumberThreshold ) then {
					_state = ACTION_STATE_COMPLETED;
				} else {
					pr _timeLeft = numberToDate [date#0, _lastCombatDateNumber + _dateNumberThreshold - (dateToNumber date)];
					OOP_INFO_1("Clearing area, time left: %1", _timeLeft);
				};
			};
		};

		// Return the current state
		T_SETV("state", _state);
		_state
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [P_THISOBJECT];
		
		// Bail if not spawned
		pr _gar = T_GETV("gar");
		if (!CALLM0(_gar, "isSpawned")) exitWith {};

		pr _AI = T_GETV("AI");
		pr _gar = T_GETV("gar");
		
		// Remove assigned goals
		pr _groups = CALLM0(_gar, "getGroups");
		{ // foreach _groups
			pr _groupAI = CALLM0(_x, "getAI");
			pr _args = ["",_AI];
			CALLM2(_groupAI, "postMethodAsync", "deleteExternalGoal", _args);
		} forEach _groups;
		
	} ENDMETHOD; 
	
	METHOD("onGarrisonSpawned") {
		params [P_THISOBJECT];

		// Reset action state so that it reactivates
		T_SETV("state", ACTION_STATE_INACTIVE);
	} ENDMETHOD;
	
	// procedural preconditions
	// POS world state property comes from action parameters
	/*
	// Don't have these preconditions any more, they are supplied by goal instead
	STATIC_METHOD("getPreconditions") {
		params [ ["_thisClass", "", [""]], ["_goalParameters", [], [[]]], ["_actionParameters", [], [[]]]];
		
		pr _pos = CALLSM2("Action", "getParameterValue", _actionParameters, TAG_POS);
		pr _ws = [WSP_GAR_COUNT] call ws_new;
		[_ws, WSP_GAR_POSITION, _pos] call ws_setPropertyValue;
		
		_ws			
	} ENDMETHOD;
	*/
	
ENDCLASS;
#include "common.hpp"

#define pr private

// Duration of this action
#define OOP_CLASS_NAME ActionGarrisonClearArea
CLASS("ActionGarrisonClearArea", "ActionGarrisonBehaviour")

	VARIABLE("pos");
	VARIABLE("radius");
	VARIABLE("lastCombatDateNumber");
	VARIABLE("durationMinutes");
	VARIABLE("regroupPos");
	VARIABLE("sweepDone");
	VARIABLE("overwatchGroups");
	VARIABLE("sweepGroups");

	public override METHOD(getPossibleParameters)
		[
			// We allow only unit OOP objects as target
			[ [TAG_POS_CLEAR_AREA, [[]]] ],	// Required parameters
			[ [TAG_CLEAR_RADIUS, [0]], [TAG_DURATION_SECONDS, [0]] ]	// Optional parameters
		]
	ENDMETHOD;

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		pr _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS_CLEAR_AREA);
		T_SETV("pos", _pos);

		pr _radius = CALLSM3("Action", "getParameterValue", _parameters, TAG_CLEAR_RADIUS, 100);
		T_SETV("radius", _radius);

		pr _durationSeconds = CALLSM3("Action", "getParameterValue", _parameters, TAG_DURATION_SECONDS, 30*60);
		pr _durationMinutes = ceil (_durationSeconds / 60); // Convert from seconds to minutes
		T_SETV("durationMinutes", _durationMinutes);

		T_SETV("lastCombatDateNumber", dateToNumber date);
		T_SETV("sweepDone", false);
		T_SETV("regroupPos", []);
		T_SETV("overwatchGroups", []);
		T_SETV("sweepGroups", []);

	ENDMETHOD;

	// logic to run when the goal is activated
	protected override METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];

		OOP_INFO_0("ACTIVATE");

		//pr _pos = T_GETV("pos");
		pr _AI = T_GETV("AI");
		pr _pos = T_GETV("pos");
		pr _radius = T_GETV("radius");

		pr _gar = GETV(_AI, "agent");

		// Find regroup position in the open, a safeish distance from the target
		pr _regroupPos = T_GETV("regroupPos");
		if(_regroupPos isEqualTo []) then {
			_regroupPos append ([_pos, _radius, _radius + 300, 20, 0, 0.3, 0, [], [_pos, _pos]] call BIS_fnc_findSafePos);
		};

		// Split to one group per vehicle
		// CALLM0(_gar, "splitVehicleGroups");

		// At this point we have one group per each vehicle
		// Ungroup vehicle groups which don't have any combat vehicles,
		// Make drivers of such vehicles join any infantry group
		pr _groups = CALLM0(_gar, "getGroups");
		pr _anyInfGroupID = _groups findIf { CALLM0(_x, "getType") == GROUP_TYPE_INF };
		if (_anyInfGroupID != -1) then {
			pr _anyInfGroup = _groups # _anyInfGroupID;
			pr _vehGroups = CALLM0(_gar, "getGroups") select { CALLM0(_x, "getType") == GROUP_TYPE_VEH; };
			OOP_INFO_0("Clearing up non-combat vehicle groups");
			{
				pr _vehGroup = _x;
				OOP_INFO_1("  Checking group: %1", _vehGroup);
				// Chech vehicle types of this vehicle group
				pr _vehUnits = CALLM0(_vehGroup, "getVehicleUnits");
				pr _countCombatVehicles = {
					pr _hO = CALLM0(_x, "getObjectHandle");
					([_hO] call misc_fnc_getFullCrew) params ["_n_driver", "_copilotTurrets", "_stdTurrets", "_psgTurrets", "_n_cargo"];
					pr _nTurrets = (count _copilotTurrets) + (count _stdTurrets);
					_nTurrets > 0;
				} count _vehUnits;
				
				// If there are no combat vehicles
				if (_countCombatVehicles == 0) then {
					OOP_INFO_0("  No combat vehicles in this group");
					// Move infantry to another group
					{
						CALLM1(_anyInfGroup, "addUnit", _x);
					} forEach CALLM0(_vehGroup, "getInfantryUnits");
					// Ungroup the vehicle so that "rebalanceGroups" doesn't attempt to assign a driver to it
					// Essentially we are marking this vehicle as useless for the job
					{
						CALLM1(_vehGroup, "removeUnit", _x);
					} forEach CALLM0(_vehGroup, "getVehicleUnits");
				} else {
					OOP_INFO_0("  There are combat vehicles in this group");
				};
			} forEach _vehGroups;

			// Clear up those empty vehicle groups, we don't need them any more
			CALLM0(_gar, "deleteEmptyGroups");
		};


		// Rebalance groups, ensure all the vehicle groups have drivers, balance the infantry groups
		// We do this explictly and not as an action precondition because we will be unbalancing the groups
		// when we assign inf protection squads to vehicle groups
		// TODO: add group protect action so we can use separate inf groups
		CALLM0(_gar, "rebalanceGroups");

		// Determine group size and type
		_groups = CALLM0(_gar, "getGroups") apply {
			[
				CALLM0(_x, "getType") == GROUP_TYPE_VEH,
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
		// Inf groups big enough to be useful
		pr _mainInfGroups = _infGroups select {
			(_x#0) > 5
		} apply {
			_x#1
		};
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
				_totalEff = _totalEff + _eff#T_EFF_aSoft + _eff#T_EFF_aMedium * 4 + _eff#T_EFF_aArmor * 8;
			} forEach _vics;
			[
				_totalEff,
				_grp
			]
		} select {
			// Only want combat capable vehicle groups for duties
			_x#0 > 0
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
			params["_prefer", "_fallback", "_target", "_validChoices"];

			private _arr = [
				_prefer arrayIntersect _validChoices,
				_fallback arrayIntersect _validChoices
			] select (count (_prefer arrayIntersect _validChoices) == 0);

			if(count _arr > 0) then {
				private _one = _arr#0;
				_target pushBack _one;
				_prefer deleteAt (_prefer find _one);
				_fallback deleteAt (_fallback find _one);
				_one
			} else {
				NULL_OBJECT
			};
		};

		pr _vehGroupsForInfAssignment = +_vehGroups;
		pr _vehGroupsOrig = +_vehGroups;

		pr _sweep = [];
		pr _overwatch = [];

		// // inf/veh group to sweep
		[_infGroups, _vehGroups, _sweep, _mainInfGroups + _vehGroups] call _fn_takeOne;
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
			private _toMove = _remainingInf select [0, 4];
			_remainingInf = _remainingInf - _toMove;
			CALLM1(_vehGroup, "addUnits", _toMove);
		};
		_infGroups = _infGroups select { !CALLM0(_x, "isEmpty") };

		// inf groups to sweep
		_sweep append _infGroups;

		// Clean up
		CALLM0(_gar, "deleteEmptyGroups");

		if(count _overwatch > 0) then {
			private _commonTags = [
				[TAG_POS, _pos],
				[TAG_CLEAR_RADIUS, _radius],
				[TAG_OVERWATCH_ELEVATION, 20],
				[TAG_BEHAVIOUR, "STEALTH"],
				[TAG_COMBAT_MODE, "RED"],
				[TAG_INSTANT, _instant],
				[TAG_OVERWATCH_DISTANCE_MIN, CLAMP(_radius, 250, 500)],
				[TAG_OVERWATCH_DISTANCE_MAX, CLAMP(_radius, 250, 500) + 250]
			];
			private _dDir = 360 / count _overwatch;
			private _dir = random 360;
			{// foreach _overwatch
				pr _groupAI = CALLM0(_x, "getAI");
				pr _args = ["GoalGroupOverwatchArea", 0, [[TAG_OVERWATCH_DIRECTION, _dir]] + _commonTags, _AI];
				CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);
				_dir = _dir + _dDir;
			} forEach _overwatch;
		};

		{// foreach _sweep
			pr _groupAI = CALLM0(_x, "getAI");
			// Vehicles move slow, inf move normal speed
			pr _speedMode = if(CALLM0(_x, "getType") == GROUP_TYPE_VEH) then {
				"LIMITED"
			} else {
				"NORMAL"
			};
			pr _args = [
				"GoalGroupClearArea",
				0,
				[
					[TAG_POS, _pos],
					[TAG_CLEAR_RADIUS, _radius],
					[TAG_BEHAVIOUR, "AWARE"],
					[TAG_COMBAT_MODE, "RED"],
					[TAG_SPEED_MODE, _speedMode],
					[TAG_INSTANT, _instant]
				],
				_AI
			];
			CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);
		} forEach _sweep;

		T_SETV("sweepGroups", _sweep);
		T_SETV("overwatchGroups", _overwatch);

		// Set last combat date
		T_SETV("lastCombatDateNumber", dateToNumber date);

		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);

		// Return ACTIVE state
		ACTION_STATE_ACTIVE

	ENDMETHOD;

	// logic to run each update-step
	public override METHOD(process)
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

		pr _state = T_CALLM0("activateIfInactive");
		if (_state == ACTION_STATE_ACTIVE) then {
			pr _AI = T_GETV("AI");
			
			// Check if we know about enemies
			pr _ws = GETV(_AI, "worldState");
			pr _awareOfEnemy = [_ws, WSP_GAR_AWARE_OF_ENEMY] call ws_getPropertyValue;
			
			if (_awareOfEnemy) then {
				T_SETV("lastCombatDateNumber", dateToNumber date); // Reset the timer
				T_SETV("sweepDone", false);
				pr _sweepGroups = T_GETV("sweepGroups");

				// Top priority goal. 
				T_CALLM1("attackEnemyBuildings", _sweepGroups); // Attack buildings occupied by enemies
			} else {
				pr _lastCombatDateNumber = T_GETV("lastCombatDateNumber");
				pr _dateNumberThreshold = dateToNumber [date#0,1,1,0, T_GETV("durationMinutes")];
				if (( (dateToNumber date) - _lastCombatDateNumber) > _dateNumberThreshold ) then {
					pr _sweepDone = T_GETV("sweepDone");
					pr _regroupPos = T_GETV("regroupPos");
					// Regroup
					pr _groups = CALLM0(_gar, "getGroups");
					if(_sweepDone) then {
						switch true do {
							// Fail if any group has failed
							case (CALLSM3("AI_GOAP", "anyAgentFailedExternalGoal", _groups, "GoalGroupMove", _AI)): {
								_state = ACTION_STATE_FAILED
							};
							// Succeed if all groups have completed the goal
							case (CALLSM3("AI_GOAP", "allAgentsCompletedExternalGoalRequired", _groups, "GoalGroupMove", _AI)): {
								_state = ACTION_STATE_COMPLETED
							};
						};
						// pr _maxDist = 0;
						// {
						// 	_maxDist = _maxDist max (_regroupPos distance2D CALLM0(_x, "getPos"));
						// } forEach _groups;
						// if(_maxDist < 100) then {
						// 	_state = ACTION_STATE_COMPLETED;
						// };
						// if()
					} else {
						T_CALLM0("clearGroupGoals");
						{
							pr _group = _x;
							pr _groupAI = CALLM0(_x, "getAI");
							// Add new goal to move to rally point
							pr _args = ["GoalGroupMove",  0, [
								[TAG_POS, _regroupPos],
								[TAG_BEHAVIOUR, "AWARE"],
								[TAG_COMBAT_MODE, "RED"],
								[TAG_SPEED_MODE, "NORMAL"],
								[TAG_MOVE_RADIUS, 100]
							], _AI];
							CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);
						} forEach _groups;

						T_SETV("sweepDone", true);
					};
				} else {
					pr _timeLeft = numberToDate [date#0, _lastCombatDateNumber + _dateNumberThreshold - (dateToNumber date)];
					OOP_INFO_1("Clearing area, time left: %1", _timeLeft);
				};
			};
		};

		// Return the current state
		T_SETV("state", _state);
		_state
	ENDMETHOD;

	public override METHOD(spawn)
		params [P_THISOBJECT];

		// Custom air spawning
		private _gar = T_GETV("gar");

		if (CALLM0(_gar, "getType") != GARRISON_TYPE_AIR) then {
			false
		} else {
			private _garPos = CALLM0(_gar, "getPos");

			{
				private _group = _x;
				if(CALLM0(_group, "isAirGroup")) then {
					CALLM1(_x, "spawnInAir", _garPos);
				} else {
					CALLM1(_x, "spawnVehiclesOnRoad", _posAndDirThisGroup);
				};

			} forEach CALLM0(_gar, "getGroups");

			// Spawn single units
			CALLSM1("ActionGarrisonMoveBase", "spawnSingleUnits", _gar);
			true
		};
	ENDMETHOD;
ENDCLASS;
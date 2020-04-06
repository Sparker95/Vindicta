#include "common.hpp"

/*
Class: ActionGroup.ActionGroupClearArea
The whole group regroups and gets some waypoints to clear the area
*/

#define pr private

CLASS("ActionGroupClearArea", "ActionGroup")

	VARIABLE("pos");
	VARIABLE("radius");
	VARIABLE("inCombat");
	VARIABLE("nextLookTime");

	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		pr _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		_pos = ZERO_HEIGHT(_pos);
		T_SETV("pos", _pos);
		pr _radius = CALLSM2("Action", "getParameterValue", _parameters, TAG_CLEAR_RADIUS);
		T_SETV("radius", _radius);

		T_SETV("inCombat", false);

		// Force aware behaviour (overwriting anything that comes in via _parameters)
		// We and using Armas auto combat to determine when to stop patrolling to engage instead
		T_SETV("behaviour", "AWARE");

		T_SETV("nextLookTime", TIME_NOW);
	} ENDMETHOD;

	// logic to run when the goal is activated
	METHOD("activate") {
		params [P_THISOBJECT, P_BOOL("_instant")];

		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");

		pr _groupType = CALLM0(_group, "getType");
		pr _isInf = _groupType in [GROUP_TYPE_IDLE, GROUP_TYPE_PATROL];

		pr _pos = T_GETV("pos");
		pr _radius = T_GETV("radius");
		pr _isUrban = (CALLSM2("Location", "nearLocations", _pos, _radius) findIf {
			CALLM0(_x, "getType") == LOCATION_TYPE_CITY
		}) != NOT_FOUND;

		pr _formation = switch true do {
			case (_isInf && _isUrban): { "STAG COLUMN" };
			case (_isInf && !_isUrban): { "WEDGE" };
			default { "COLUMN" };
		};

		// Set behaviour
		T_CALLM4("applyGroupBehaviour", _formation, "AWARE", "RED", "NORMAL");
		T_CALLM0("regroup");
		T_CALLM0("clearWaypoints");

		// Give some waypoints
		T_PRVAR(hG);
		private _wp0 = _hG addWaypoint [_pos, _radius];
		_wp0 setWaypointCompletionRadius 20;
		_wp0 setWaypointType "SAD";
		for "_i" from 0 to 8 do {
			private _wp = _hG addWaypoint [_pos, _radius];
			_wp setWaypointCompletionRadius 20;
			_wp setWaypointType "SAD";
		};
		_hG setCurrentWaypoint [_hG, 0];

		if(_isUrban || !_isInf) then {
			// Try and move all waypoints on to nearby roads
			{
				pr _pos = getWPPos _x;
				pr _nearestRoad = [_pos, 50] call BIS_fnc_nearestRoad;
				if(!isNull _nearestRoad) then {
					_x setWPPos position _nearestRoad;
				};
			} forEach (waypoints _hG);
		};

		// Create a cycle waypoint
		pr _wpCycle = _hG addWaypoint [waypointPosition _wp0, 0];
		_wpCycle setWaypointType "CYCLE";

		// Add goals to units
		pr _inf = CALLM0(_group, "getInfantryUnits");

		if(_isInf) then {
			{
				pr _unitAI = CALLM0(_x, "getAI");
				CALLM4(_unitAI, "addExternalGoal", "GoalUnitInfantryRegroup", 0, [[TAG_INSTANT ARG _instant]], _AI);
			} forEach _inf;
		};

		T_CALLM0("updateVehicleAssignments");

		if(_instant) then {
			T_CALLM1("teleport", waypointPosition _wp0);
		};

		T_SETV("nextLookTime", TIME_NOW);

		// Return ACTIVE state
		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE

	} ENDMETHOD;

	// logic to run each update-step
	METHOD("process") {
		params [P_THISOBJECT];

		T_CALLM0("failIfEmpty");

		private _state = T_CALLM0("activateIfInactive");

		if(_state == ACTION_STATE_ACTIVE && {TIME_NOW > T_GETV("nextLookTime")}) then {
			private _pos = T_GETV("pos");
			private _radius = T_GETV("radius");
			private _hG = T_GETV("hG");

			// All units looking around all the time

			// player is near?
			private _allTargets = [];
			{
				_allTargets append (_x targetsQuery [objNull, sideUnknown, "", [], 40]);
			} forEach units _hG;

			private _targets = _allTargets select {
				_x#2 != side _hG && {_x#3 in ["Man", "Vehicle"]} 
			} apply {
				_x#1
			};
			private _playerTargets = _targets arrayIntersect allPlayers;
			if(count _playerTargets > 0 || {count _targets > 0 && random 5 < 4}) then {
				private _tgts = if(count _playerTargets > 0) then { _playerTargets } else { _targets };
				{
					private _tgt = selectRandom _tgts;
					_x glanceAt _tgt;
					_x lookAt _tgt;
					_x commandWatch _tgt;
				} foreach units _hG;

				private _nextLookTime = TIME_NOW + random[5, 15, 30];
				T_SETV("nextLookTime",  _nextLookTime);
			} else {
				{
					private _lookAtPos = position leader _hG getPos [random [15, 30, 50], direction vehicle leader _hG + random [-45, 0, 45]];// +  [[[position leader _hG, _radius]]] call BIS_fnc_randomPos;
					_x glanceAt _lookAtPos;
					_x lookAt _lookAtPos;
					_x commandWatch _lookAtPos;
				} foreach units _hG;

				private _nextLookTime = TIME_NOW + random[0, 5, 15];
				T_SETV("nextLookTime",  _nextLookTime);
			};
		};

		// This action is terminal because it's never over right now

		// Delete all waypoints when we know about some enemies
		private _hG = T_GETV("hG");

		if (count waypoints _hG <= 1) then {
			// Force reactivation
			T_SETV("state", ACTION_STATE_INACTIVE);
		};

		// This doesn't really improve behavior...
		// if (behaviour leader _hG == "COMBAT") then {
		// 	if (!T_GETV("inCombat")) then {
		// 		// Delete waypoints once, let them chose what to do on their own
		// 		T_CALLM0("clearWaypoints");
		// 		OOP_INFO_0("Deleted waypoints");
		// 		T_SETV("inCombat", true);
		// 	};
		// 	private _enemySides = [east, west, independent] select { !([side _hG, _x] call BIS_fnc_sideIsFriendly) };
		// 	private _enemies = leader _hG targetsQuery [objNull, sideUnknown, "", position leader _hG, 0/*TARGET_AGE_TO_REVEAL*/] select {
		// 		_x#2 in _enemySides
		// 	};
		// } else {
		// 	if (T_GETV("inCombat") || count waypoints _hG <= 1) then {
		// 		T_SETV("inCombat", false);
		// 		// Force reactivation
		// 		T_SETV("state", ACTION_STATE_INACTIVE);
		// 	};
		// };
		//ACTION_STATE_ACTIVE

		// Return the current state
		T_GETV("state")
	} ENDMETHOD;

	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [P_THISOBJECT];

		T_CALLM0("clearWaypoints");
		T_CALLCM0("ActionGroup", "terminate");

	} ENDMETHOD;

ENDCLASS;
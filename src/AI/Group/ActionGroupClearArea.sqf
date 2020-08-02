#include "common.hpp"
FIX_LINE_NUMBERS()

/*
Class: ActionGroup.ActionGroupClearArea
The whole group regroups and gets some waypoints to clear the area
*/

#define pr private

#define OOP_CLASS_NAME ActionGroupClearArea
CLASS("ActionGroupClearArea", "ActionGroup")

	VARIABLE("pos");
	VARIABLE("radius");
	VARIABLE("inCombat");
	VARIABLE("nextLookTime");

	public override METHOD(getPossibleParameters)
		[
			[ [TAG_POS, [[]]], [TAG_CLEAR_RADIUS, [0]] ],	// Required parameters
			[  ]	// Optional parameters
		]
	ENDMETHOD;

	METHOD(new)
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

		T_SETV("nextLookTime", GAME_TIME);
	ENDMETHOD;

	// logic to run when the goal is activated
	protected override METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];

		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");

		pr _groupType = CALLM0(_group, "getType");
		pr _isInf = _groupType == GROUP_TYPE_INF;
		pr _isAir = CALLM0(_group, "isAirGroup");

		pr _pos = T_GETV("pos");
		pr _radius = T_GETV("radius");
		pr _isUrban = (CALLSM2("Location", "overlappingLocations", _pos, _radius) findIf {
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

		private _hG = T_GETV("hG");

		// A random bunch of waypoints to get them to move around a bit
		for "_i" from 0 to 10 do {
			private _radius0 = _radius;
			if (_i == 0) then {	_radius0 = 35; };
			private _rpos = [[[_pos, _radius0]], [], {_isAir || !surfaceIsWater _this}] call BIS_fnc_randomPos;
			// BIS_fnc_randomPos returns [0,0] if it couldn't find anywhere, so we ignore these points
			if(count _rpos == 3) then {
				private _wp = _hG addWaypoint [AGLToASL _rpos, -1];
				_wp setWaypointType "SAD";
			};
		};

		if(!_isAir && (_isUrban || !_isInf)) then {
			// Try and move all waypoints on to nearby roads for urban areas or ground vehicles
			{
				pr _pos = getWPPos _x;
				pr _nearestRoad = [_pos, 50] call BIS_fnc_nearestRoad;
				if(!isNull _nearestRoad) then {
					_x setWPPos position _nearestRoad;
				};
			} forEach waypoints _hG;
		};

		pr _wp0Pos = waypointPosition [_hG, 0];
		// Create a cycle waypoint
		pr _wpCycle = _hG addWaypoint [AGLToASL _wp0Pos, -1];
		_wpCycle setWaypointType "CYCLE";
		_hG setCurrentWaypoint [_hG, 0];

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
			T_CALLM1("teleport", _wp0Pos);
		};

		T_SETV("nextLookTime", GAME_TIME);

		// Return ACTIVE state
		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE

	ENDMETHOD;

	// logic to run each update-step
	public override METHOD(process)
		params [P_THISOBJECT];

		T_CALLM0("failIfEmpty");

		private _state = T_CALLM0("activateIfInactive");

		if(_state == ACTION_STATE_ACTIVE && { GAME_TIME > T_GETV("nextLookTime") }) then {
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
					_x doWatch _tgt;
				} foreach units _hG;

				private _nextLookTime = GAME_TIME + random[5, 15, 30];
				T_SETV("nextLookTime",  _nextLookTime);
			} else {
				{
					private _lookAtPos = position leader _hG getPos [random [15, 30, 50], direction vehicle leader _hG + random [-45, 0, 45]];// +  [[[position leader _hG, _radius]]] call BIS_fnc_randomPos;
					_x glanceAt _lookAtPos;
					_x lookAt _lookAtPos;
					_x doWatch _lookAtPos;
				} foreach units _hG;

				private _nextLookTime = GAME_TIME + random[0, 5, 15];
				T_SETV("nextLookTime",  _nextLookTime);
			};
		};

		// This action doesn't return completed ever, it will run until the goal is made non-relevant or removed

		private _hG = T_GETV("hG");

		if (waypointType (waypoints _hG select currentWaypoint _hG) != "SAD") then {
			// Force reactivation to regenerate the waypoints
			T_SETV("state", ACTION_STATE_INACTIVE);
		};

		// Return the current state
		T_GETV("state")
	ENDMETHOD;

	// logic to run when the action is satisfied
	public override METHOD(terminate)
		params [P_THISOBJECT];

		T_CALLCM0("ActionGroup", "terminate");
		T_CALLM0("clearWaypoints");
		T_CALLCM0("ActionGroup", "terminate");

	ENDMETHOD;

ENDCLASS;
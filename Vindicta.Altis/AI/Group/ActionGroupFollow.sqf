#include "common.hpp"

/*
Infantry group will follow its target
*/

#define WAYPOINT_UPDATE_INTERVAL 17

#define OOP_CLASS_NAME ActionGroupFollow
CLASS("ActionGroupFollow", "ActionGroup")

	VARIABLE("hGroupToFollow");
	VARIABLE("nextWaypointUpdateTime");

	METHOD(getPossibleParameters)
		[
			[ [TAG_TARGET, [grpNull]]],	// Required parameters
			[  ]	// Optional parameters
		]
	ENDMETHOD;

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		private _hGroupToFollow = CALLSM2("Action", "getParameterValue", _parameters, TAG_TARGET);
		T_SETV("hGroupToFollow", _hGroupToFollow);

		T_SETV("nextWaypointUpdateTime", GAME_TIME + WAYPOINT_UPDATE_INTERVAL);
	ENDMETHOD;

	METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];

		private _group = T_GETV("group");

		T_CALLM0("clearWaypoints");

		if(count CALLM0(_group, "getVehicleUnits") > 0) then {
			T_CALLM4("applyGroupBehaviour", "COLUMN", "CARELESS", "YELLOW", "NORMAL");
		} else {
			T_CALLM4("applyGroupBehaviour", "STAG COLUMN", "AWARE", "YELLOW", "NORMAL");
		};

		// T_CALLM2("applyGroupBehaviour", "COLUMN", "AWARE");

		T_CALLM0("regroup");

		T_SETV("nextWaypointUpdateTime", GAME_TIME + WAYPOINT_UPDATE_INTERVAL);
		T_SETV("state", ACTION_STATE_ACTIVE);

		ACTION_STATE_ACTIVE
	ENDMETHOD;

	METHOD(process)
		params [P_THISOBJECT];

		if(T_CALLM0("failIfNoInfantry") == ACTION_STATE_FAILED) exitWith {
			ACTION_STATE_FAILED
		};

		private _state = T_CALLM0("activateIfInactive");

		if (_state == ACTION_STATE_ACTIVE && {GAME_TIME > T_GETV("nextWaypointUpdateTime")}) then {
			// Give a new waypoint periodycally
			private _group = T_GETV("group");
			private _hGroupToFollow = T_GETV("hGroupToFollow");
			private _hG = T_GETV("hG");

			if (leader _hG distance leader _hGroupToFollow > 30) then {

				private _pos = getPos leader _hGroupToFollow;

				private _leader = CALLM0(_group, "getLeader");
				private _leaderAI = CALLM0(_leader, "getAI");
				private _infUnits = CALLM0(_group, "getInfantryUnits");

				// Just move on foot
				private _parameters = [
					[TAG_MOVE_TARGET, _pos],
					[TAG_MOVE_RADIUS, 20]
				];
				CALLM4(_leaderAI, "addExternalGoal", "GoalUnitInfantryMove", 0, _parameters, _AI);

				// Everyone else must regroup
				{
					private _ai = CALLM0(_x, "getAI");
					private _parameters = [];
					private _args = ["GoalUnitInfantryRegroup", 0, _parameters, _AI, true, false, true]; // Will be always active, even when completed
					CALLM(_ai, "addExternalGoal", _args);
				} forEach (_infUnits - [_leader]);

				T_SETV("nextWaypointUpdateTime", GAME_TIME + WAYPOINT_UPDATE_INTERVAL);
			};
		};

		T_SETV("state", _state);
		_state
	ENDMETHOD;

	METHOD(terminate)
		params [P_THISOBJECT];
		T_CALLCM0("ActionGroup", "terminate");
	ENDMETHOD;

ENDCLASS;

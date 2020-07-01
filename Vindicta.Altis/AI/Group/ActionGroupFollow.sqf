#include "common.hpp"

/*
Infantry group will follow its target
*/

#define WAYPOINT_UPDATE_INTERVAL 10

#define OOP_CLASS_NAME ActionGroupFollow
CLASS("ActionGroupFollow", "ActionGroup")

	VARIABLE("hTargetToFollow"); // Object or group
	VARIABLE("nextWaypointUpdateTime");
	VARIABLE("followRadius");

	public override METHOD(getPossibleParameters)
		[
			[ [TAG_TARGET, [grpNull, objNull]]],	// Required parameters
			[ [TAG_FOLLOW_RADIUS, [0]] ]	// Optional parameters
		]
	ENDMETHOD;

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		private _hTargetToFollow = CALLSM2("Action", "getParameterValue", _parameters, TAG_TARGET);
		T_SETV("hTargetToFollow", _hTargetToFollow);

		private _radius = GET_PARAMETER_VALUE_DEFAULT(_parameters, TAG_FOLLOW_RADIUS, 30);
		T_SETV("followRadius", _radius);

		T_SETV("nextWaypointUpdateTime", GAME_TIME + WAYPOINT_UPDATE_INTERVAL);
	ENDMETHOD;

	protected override METHOD(activate)
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

	public override METHOD(process)
		params [P_THISOBJECT];

		if(T_CALLM0("failIfNoInfantry") == ACTION_STATE_FAILED) exitWith {
			ACTION_STATE_FAILED
		};

		private _state = T_CALLM0("activateIfInactive");

		if (_state == ACTION_STATE_ACTIVE && {GAME_TIME > T_GETV("nextWaypointUpdateTime")}) then {
			// Give a new waypoint periodycally
			private _group = T_GETV("group");
			private _hTargetToFollow = T_GETV("hTargetToFollow");
			private _hG = T_GETV("hG");

			private _objectToFollow = if (_hTargetToFollow isEqualType grpNull) then {
				leader _hTargetToFollow;
			} else {
				_hTargetToFollow;
			};

			// Bail if target is null
			if (isNull _objectToFollow) exitWith {
				T_SETV("state", ACTION_STATE_FAILED);
				ACTION_STATE_FAILED;
			};

			if ((leader _hG) distance _objectToFollow > T_GETV("followRadius")) then {

				private _pos = getPos leader _hTargetToFollow;

				private _leader = CALLM0(_group, "getLeader");
				private _leaderAI = CALLM0(_leader, "getAI");
				private _infUnits = CALLM0(_group, "getInfantryUnits");

				// Just move on foot
				private _parameters = [
					[TAG_MOVE_TARGET, _pos],
					[TAG_MOVE_RADIUS, T_GETV("followRadius")*0.666] // 2/3
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

	public override METHOD(terminate)
		params [P_THISOBJECT];
		T_CALLCM0("ActionGroup", "terminate");
	ENDMETHOD;

	public override METHOD(getDebugUIVariableNames)
		["hTargetToFollow", "nextWaypointUpdateTime", "followRadius"];
	ENDMETHOD;

ENDCLASS;

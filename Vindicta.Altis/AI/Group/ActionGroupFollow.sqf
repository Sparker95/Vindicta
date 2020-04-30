#include "common.hpp"

#define WAYPOINT_UPDATE_INTERVAL 17

#define OOP_CLASS_NAME ActionGroupFollow
CLASS("ActionGroupFollow", "ActionGroup")

	VARIABLE("hGroupToFollow");
	VARIABLE("nextWaypointUpdateTime");

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
				// Delete all old waypoints and add a new one
				T_CALLM0("clearWaypoints");

				private _pos = position leader _hGroupToFollow;
				private _wp = _hG addWaypoint [_pos, 4, 0];
				_wp setWaypointType "MOVE";
				_hG setCurrentWaypoint _wp;

				T_SETV("nextWaypointUpdateTime", GAME_TIME + WAYPOINT_UPDATE_INTERVAL);
			};
		};

		T_SETV("state", _state);
		_state
	ENDMETHOD;

ENDCLASS;

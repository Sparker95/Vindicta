#include "common.hpp"

// Class: ActionGroup.ActionGroupWatchPosition

#define OOP_CLASS_NAME ActionGroupWatchPosition
CLASS("ActionGroupWatchPosition", "ActionGroup")
	VARIABLE("pos");
	VARIABLE("radius");
	VARIABLE("nextLookTime");

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		private _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		T_SETV("pos", ZERO_HEIGHT(_pos));
		private _radius = CALLSM3("Action", "getParameterValue", _parameters, TAG_CLEAR_RADIUS, 100);
		T_SETV("radius", _radius);
		T_SETV("nextLookTime", GAME_TIME);
	ENDMETHOD;

	// logic to run when the goal is activated
	METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];

		T_CALLM0("clearWaypoints");
		T_CALLM0("regroup");
		T_CALLM0("applyGroupBehaviour");

		if(_instant) then {
			private _pos = T_GETV("pos");
			private _hG = T_GETV("hG");
			vehicle leader _hG setDir (vehicle leader _hG getDir _pos);
		};

		T_SETV("nextLookTime", GAME_TIME);

		// if(terrainIntersect [_pos vectorAdd [0, 0, 1], position leader _hG vectorAdd [0, 0, 1]]) then {
		// 	// Failed, can't see the target position
		// } else {
		// }

		// Return ACTIVE state
		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
	ENDMETHOD;
	
	// logic to run each update-step
	METHOD(process)
		params [P_THISOBJECT];

		private _state = T_CALLM0("activateIfInactive");
		if(_state == ACTION_STATE_ACTIVE && {GAME_TIME > T_GETV("nextLookTime")}) then {
			private _pos = T_GETV("pos");
			private _radius = T_GETV("radius");

			private _hG = T_GETV("hG");
			// Just all watch it for now, later we can have something more smarterrer
			// units _hG lookAt _lookAtPos;
			_hG setFormDir (vehicle leader _hG getDir _pos);
			units _hG doFollow leader _hG;
			{
				private _lookAtPos = [[[_pos, _radius]]] call BIS_fnc_randomPos;
				_x glanceAt _lookAtPos;
				_x lookAt _lookAtPos;
				_x doWatch _lookAtPos;
			} foreach units _hG;

			private _nextLookTime = GAME_TIME + random[0, 10, 15];
			T_SETV("nextLookTime",  _nextLookTime);
		};
		_state
	ENDMETHOD;

	// logic to run when the action is satisfied
	METHOD(terminate)
		params [P_THISOBJECT];
		private _hG = T_GETV("hG");

		// All stop watching position
		units _hG doWatch objNull;
	ENDMETHOD;

ENDCLASS;
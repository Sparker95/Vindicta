#include "common.hpp"

// Class: ActionGroup.ActionGroupWatchPosition

CLASS("ActionGroupWatchPosition", "ActionGroup")
	VARIABLE("pos");

	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		private _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		T_SETV("pos", ZERO_HEIGHT(_pos));
	} ENDMETHOD;

	// logic to run when the goal is activated
	METHOD("activate") {
		params [P_THISOBJECT];

		T_CALLM0("clearWaypoints");
		T_CALLM0("regroup");
		T_CALLM0("applyGroupBehaviour");

		private _pos = T_GETV("pos");
		private _hG = T_GETV("hG");

		// if(terrainIntersect [_pos vectorAdd [0, 0, 1], position leader _hG vectorAdd [0, 0, 1]]) then {
		// 	// Failed, can't see the target position
		// } else {
		// }

		// Just all watch it for now, later we can have something more smarterrer
		units _hG commandWatch _pos;

		// {
		// 	switch true do {
		// 		case vehicle _x != _x && gunner vehicle _x == _x: {
		// 			_x commandWatch _pos;
		// 		};
		// 		case vehicle _x != _x && commander vehicle _x == _x: {
		// 			_x scanHor _pos;
		// 		};
		// 	}
		// } forEach (units _hG);

		// Give watch position order

		// Return ACTIVE state
		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [P_THISOBJECT];
		
		private _state = T_CALLM0("activateIfInactive");

		_state
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [P_THISOBJECT];
		private _hG = T_GETV("hG");

		// All stop watching position
		units _hG commandWatch objNull;
	} ENDMETHOD;

ENDCLASS;
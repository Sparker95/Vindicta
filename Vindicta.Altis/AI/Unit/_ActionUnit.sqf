#include "common.hpp"

/*
Unit action.
*/

#define pr private

#define THIS_ACTION_NAME "MyAction"

CLASS("ActionUnit", "Action")

	VARIABLE("hO");
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]] ];
		
		pr _a = GETV(_AI, "agent"); // cache the object handle
		pr _oh = CALLM(_a, "getObjectHandle", []);
		SETV(_thisObject, "hO", _oh);
	} ENDMETHOD;

	METHOD("clearWaypoints") {
		params [P_THISOBJECT];
		private _hO = T_GETV("hO");
		private _hG = group _hO;
		while { count waypoints _hG > 0 } do {
			deleteWaypoint ((waypoints _hG)#0);
		};
		//_hG addWaypoint [position leader _hG, 0];
		//doStop _hO;
	} ENDMETHOD;
			
	METHOD("regroup") {
		params [P_THISOBJECT];

		private _hG = group T_GETV("hO");
		{ _x stop false; _x doFollow leader _hG; } forEach units _hG;
	} ENDMETHOD;
ENDCLASS;
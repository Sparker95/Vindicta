#include "common.hpp"

/*
Unit action.
*/

CLASS("ActionUnit", "Action")
	VARIABLE("hO");

	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI")];
		private _a = GETV(_AI, "agent"); // cache the object handle
		private _oh = CALLM(_a, "getObjectHandle", []);
		SETV(_thisObject, "hO", _oh);
	} ENDMETHOD;

	METHOD("clearWaypoints") {
		params [P_THISOBJECT];
		private _hO = T_GETV("hO");
		CALLSM1("Action", "_clearWaypoints", group _hO);
	} ENDMETHOD;
			
	METHOD("regroup") {
		params [P_THISOBJECT];
		private _hO = T_GETV("hO");
		CALLSM1("Action", "_regroup", group _hO);
	} ENDMETHOD;
ENDCLASS;
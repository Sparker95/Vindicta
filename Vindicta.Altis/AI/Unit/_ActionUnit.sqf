#include "common.hpp"

/*
Unit action.
*/

CLASS("ActionUnit", "Action")
	VARIABLE("hO");

	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI")];
		private _a = GETV(_AI, "agent"); // cache the object handle
		private _oh = CALLM0(_a, "getObjectHandle");
		T_SETV("hO", _oh);
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

	METHOD("teleport") {
		params [P_THISOBJECT, P_POSITION("_pos")];
		private _AI = T_GETV("AI");
		private _unit = GETV(_AI, "agent");
		CALLSM2("Action", "_teleport", [_unit], _pos);
	} ENDMETHOD;
	
	METHOD("teleportGroup") {
		params [P_THISOBJECT, P_POSITION("_pos")];
		private _AI = T_GETV("AI");
		private _unit = GETV(_AI, "agent");
		private _group = CALLM0(_unit, "getGroup");
		private _units = CALLM0(_group, "getUnits");
		CALLSM2("Action", "_teleport", _units, _pos);
	} ENDMETHOD;
ENDCLASS;
#include "common.hpp"

/*
Unit action.
*/

#define OOP_CLASS_NAME ActionUnit
CLASS("ActionUnit", "Action")
	VARIABLE("hO");

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI")];
		private _a = GETV(_AI, "agent"); // cache the object handle
		private _oh = CALLM0(_a, "getObjectHandle");
		T_SETV("hO", _oh);
	ENDMETHOD;

	METHOD(clearWaypoints)
		params [P_THISOBJECT];
		private _hO = T_GETV("hO");
		CALLSM1("Action", "_clearWaypoints", group _hO);
	ENDMETHOD;

	METHOD(regroup)
		params [P_THISOBJECT];
		private _hO = T_GETV("hO");
		CALLSM1("Action", "_regroup", group _hO);
	ENDMETHOD;

	METHOD(teleport)
		params [P_THISOBJECT, P_POSITION("_pos")];
		private _AI = T_GETV("AI");
		private _unit = GETV(_AI, "agent");
		CALLSM2("Action", "_teleport", [_unit], _pos);
	ENDMETHOD;
	
	METHOD(teleportGroup)
		params [P_THISOBJECT, P_POSITION("_pos")];
		private _AI = T_GETV("AI");
		private _unit = GETV(_AI, "agent");
		private _group = CALLM0(_unit, "getGroup");
		private _units = CALLM0(_group, "getUnits");
		CALLSM2("Action", "_teleport", _units, _pos);
	ENDMETHOD;

	METHOD(bumpVehicle)
		params [P_THISOBJECT, P_OBJECT("_hVeh"), P_NUMBER("_amount")];
		private _pushdir = 0;
		if(_amount <= 0) then { _amount = 5; };
		// unit is stuck
		if ((lineintersectssurfaces [_hVeh modeltoworldworld [0,0,0.2], _hVeh modeltoworldworld [0,8,0.2], _hVeh]) isEqualTo []) then {
			//push it forwards a little
			_pushdir = _amount;
		} else {
			// if there's something in front, push backwards, not forwards
			_pushdir = -_amount;
		};
		_hVeh setVelocityModelSpace [0, _pushdir, 0];
	ENDMETHOD;
	
ENDCLASS;
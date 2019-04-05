#include "..\..\..\OOP_Light\OOP_Light.h"

// Collection of unitCount/vehCount and their orders
CLASS("GarrisonModel", "RefCounted")
	// Use realGarr as id? Won't work for garrison created in sim though
	VARIABLE("id");
	VARIABLE("realGarr");
	VARIABLE("ownerState");
	VARIABLE("efficiency");
	VARIABLE_ATTR("order", [ATTR_REFCOUNTED]);
	VARIABLE_ATTR("currAction", [ATTR_REFCOUNTED]);
	VARIABLE("inCombat");
	VARIABLE("pos");
	VARIABLE("garrSide");

	VARIABLE("outpostId");

	METHOD("new") {
		params [P_THISOBJECT, P_STRING("_ownerState"), P_STRING("_realGarr")];
		T_SETV("id", -1);
		T_SETV("ownerState", _ownerState);
		T_SETV("efficiency", []);
		T_SETV_REF("order", objNull);
		T_SETV_REF("currAction", objNull);
		T_SETV("inCombat", false);
		T_SETV("pos", []);
		T_SETV("garrSide", objNull);
		T_SETV("outpostId", -1);

		if(_realGarr isEqualTo "") then {
			T_SETV("realGarr", objNull);
			ASSERT_MSG(GETV(_ownerState, "isSim"), "State must be sim if you aren't setting realGarr");
		} else {
			T_SETV("realGarr", _realGarr);
			ASSERT_MSG(!GETV(_ownerState, "isSim"), "State must NOT be sim if you are setting realGarr");
			T_CALLM("syncFromRealGarr", []);
		};
	} ENDMETHOD;

	METHOD("setId") {
		params [P_THISOBJECT, P_NUMBER("_id")];
		T_SETV("id", _id);
	} ENDMETHOD;
	
	METHOD("syncFromRealGarr") {
		params [P_THISOBJECT];

		T_PRVAR(realGarr);
		// If we have an assigned real garrison then sync from it
		if(_realGarr isEqualType "") then {
			OOP_DEBUG_1("Updating GarrisonModel from Garrison %1", _realGarr);
			T_SETV("efficiency", GETV(_realGarr, "effTotal"));
			T_SETV("pos", CALLM(_realGarr, "getPos", []));
			T_SETV("garrSide", GETV(_realGarr, "side"));
		};
	} ENDMETHOD;

	METHOD("update") {
		params [P_THISOBJECT];

		T_CALLM("syncFromRealGarr", []);

		// T_PRVAR(ownerState);
		// // If we have an assigned owner state then ???
		// if(_ownerState isEqualType "") then {

		// }

		// Update order? Yes, action shouldn't do it, orders are owned by garrison
		T_PRVAR(order);

		if(_order isEqualType "") then {
			CALLM(_order, "update", [_thisObject]);
		};
	} ENDMETHOD;

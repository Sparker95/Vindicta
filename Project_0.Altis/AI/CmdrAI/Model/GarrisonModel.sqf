#include "..\..\..\OOP_Light\OOP_Light.h"


// Collection of unitCount/vehCount and their orders
CLASS("GarrisonModel", "RefCounted")
	VARIABLE("id");
	VARIABLE("ownerState");
	VARIABLE("efficiency");
	VARIABLE_ATTR("order", [ATTR_REFCOUNTED]);
	VARIABLE_ATTR("currAction", [ATTR_REFCOUNTED]);
	VARIABLE("inCombat");
	VARIABLE("pos");
	VARIABLE("garrSide");

	VARIABLE("outpostId");

	METHOD("new") {
		params [P_THISOBJECT, P_STRING("_ownerState")];
		T_SETV("id", -1);
		T_SETV("ownerState", _ownerState);
		T_SETV("efficiency", []);
		T_SETV_REF("order", objNull);
		T_SETV_REF("currAction", objNull);
		T_SETV("inCombat", false);
		T_SETV("pos", []);
		T_SETV("garrSide", side_none);
		T_SETV("outpostId", -1);
	} ENDMETHOD;

	METHOD("updateFromRealGarrison") {
		params [P_THISOBJECT, P_STRING("_realGarr")];

		OOP_INFO_1("Updating GarrisonModel from %1", _realGarr);

		T_SETV("efficiency", GETV(_realGarr, ""));
		T_SETV("vehCount", _vehCount);
		T_SETV("inCombat", false);
		T_SETV("pos", markerPos _marker);
		T_SETV("garrSide", markerColor _marker);
	} ENDMETHOD;

	METHOD("setId") {
		params [P_THISOBJECT, P_NUMBER("_id")];
		T_SETV("id", _id);
		T_CALLM0("updateMarkerText");
	} ENDMETHOD;
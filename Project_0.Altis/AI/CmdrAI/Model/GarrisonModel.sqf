#include "..\..\..\OOP_Light\OOP_Light.h"

// Model of a Real Garrison. This can either be the Actual model or the Sim model.
// The Actual model represents the Real Garrison as it currently is. A Sim model
// is a copy that is modified during simulations.
CLASS("GarrisonModel", "ModelBase")
	// Strength vector of the garrison.
	VARIABLE("efficiency");
	//// Current order the garrison is following.
	// TODO: do we want this? I think only real Garrison needs orders, model just has action.
	//VARIABLE_ATTR("order", [ATTR_REFCOUNTED]);
	VARIABLE_ATTR("currAction", [ATTR_REFCOUNTED]);
	// Is the garrison currently in combat?
	// TODO: maybe replace this with with "engagement score" indicating how engaged they are.
	VARIABLE("inCombat");
	// Position.
	VARIABLE("pos");
	// What side this garrison belongs to.
	VARIABLE("side");
	// Id of the location the garrison is currently occupying.
	VARIABLE("locationId");

	METHOD("new") {
		params [P_THISOBJECT, P_STRING("_ownerState"), P_STRING("_realGarr")];
		T_SETV_REF("order", objNull);
		T_SETV_REF("currAction", objNull);
		// These will get set in sync
		// T_SETV("efficiency", []);
		// T_SETV("inCombat", false);
		// T_SETV("pos", []);
		// T_SETV("side", objNull);
		// T_SETV("locationId", -1);
		T_CALLM("sync", []);
	} ENDMETHOD;

	METHOD("setId") {
		params [P_THISOBJECT, P_NUMBER("_id")];
		T_SETV("id", _id);
	} ENDMETHOD;
	
	METHOD("sync") {
		params [P_THISOBJECT];

		T_PRVAR(realObject);
		// If we have an assigned real garrison then sync from it
		if(_realObject isEqualType "") then {
			OOP_DEBUG_1("Updating GarrisonModel from Garrison %1", _realObject);
			T_SETV("efficiency", GETV(_realObject, "effTotal"));
			T_SETV("pos", CALLM(_realObject, "getPos", []));
			T_SETV("side", GETV(_realObject, "side"));
		};
	} ENDMETHOD;
ENDCLASS;
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
	VARIABLE_ATTR("action", [ATTR_REFCOUNTED]);
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
		params [P_THISOBJECT, P_STRING("_world"), P_STRING("_actual")];
		//T_SETV_REF("order", objNull);
		T_SETV_REF("action", objNull);
		// These will get set in sync
		T_SETV("efficiency", []);
		T_SETV("inCombat", false);
		T_SETV("pos", []);
		T_SETV("side", objNull);
		T_SETV("locationId", -1);
		T_CALLM("sync", []);
	} ENDMETHOD;

	METHOD("simCopy") {
		params [P_THISOBJECT, P_STRING("_targetWorldModel")];
		private _copy = NEW("GarrisonModel", [_targetWorldModel]+[""]);
		SETV(_copy, "id", T_GETV("id"));
		SETV(_copy, "efficiency", +T_GETV("efficiency"));
		//SETV_REF(_copy, "order", T_GETV("order"));
		SETV_REF(_copy, "action", T_GETV("action"));
		SETV(_copy, "inCombat", T_GETV("inCombat"));
		SETV(_copy, "pos", +T_GETV("pos"));
		SETV(_copy, "side", T_GETV("side"));
		SETV(_copy, "locationId", T_GETV("locationId"));
		_copy
	} ENDMETHOD;

	METHOD("setId") {
		params [P_THISOBJECT, P_NUMBER("_id")];
		T_SETV("id", _id);
	} ENDMETHOD;
	
	METHOD("sync") {
		params [P_THISOBJECT];

		T_PRVAR(actual);
		// If we have an assigned real garrison then sync from it
		if(_actual isEqualType "") then {
			OOP_DEBUG_1("Updating GarrisonModel from Actual Garrison %1", _actual);
			T_SETV("efficiency", GETV(_actual, "effTotal"));
			T_SETV("pos", CALLM(_actual, "getPos", []));
			T_SETV("side", GETV(_actual, "side"));
		};
	} ENDMETHOD;

	METHOD("killed") {
		params [P_THISOBJECT];
		T_PRVAR(world);
		T_SETV("efficiency", []);
		CALLM(_world, "garrisonKilled", [_thisObject]);
	} ENDMETHOD;

	METHOD("getAction") {
		params [P_THISOBJECT];
		T_GETV("action")
	} ENDMETHOD;

	METHOD("setAction") {
		params [P_THISOBJECT, P_STRING("_action")];
		T_SETV_REF("action", _action);
	} ENDMETHOD;

	METHOD("clearAction") {
		params [P_THISOBJECT];
		T_SETV_REF("action", objNull);
	} ENDMETHOD;

	METHOD("isDead") {
		params [P_THISOBJECT];
		T_PRVAR(efficiency);
		count _efficiency == 0
	} ENDMETHOD;

	METHOD("getLocation") {
		params [P_THISOBJECT];
		T_PRVAR(locationId);
		T_PRVAR(world);
		if(_locationId != -1) exitWith { CALLM(_world, "getLocation", [_locationId]) };
		objNull
	} ENDMETHOD;
ENDCLASS;


// Unit test
#ifdef _SQF_VM

["GarrisonModel.new(actual)", {
	private _actual = NEW("Garrison", [WEST]);
	private _world = NEW("WorldModel", [false]);
	private _garrison = NEW("GarrisonModel", [_world] + [_actual]);
	private _class = OBJECT_PARENT_CLASS_STR(_garrison);
	!(isNil "_class")
}] call test_AddTest;

["GarrisonModel.new(sim)", {
	private _world = NEW("WorldModel", [true]);
	private _garrison = NEW("GarrisonModel", [_world]+[""]);
	private _class = OBJECT_PARENT_CLASS_STR(_garrison);
	!(isNil "_class")
}] call test_AddTest;

["GarrisonModel.delete", {
	private _world = NEW("WorldModel", [true]);
	private _garrison = NEW("GarrisonModel", [_world]+[""]);
	DELETE(_garrison);
	private _class = OBJECT_PARENT_CLASS_STR(_garrison);
	isNil "_class"
}] call test_AddTest;

#endif
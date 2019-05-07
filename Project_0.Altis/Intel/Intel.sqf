#include "..\OOP_Light\OOP_Light.h"

/*
Classes of intel items
Author: Sparker 05.05.2019
*/

CLASS("Intel", "")

	VARIABLE("timeCreated");
	VARIABLE("timeUpdated");
	VARIABLE("source"); // Ref to the source intel item

	METHOD("new") {
		params ["_thisObject"];
		/*
		T_SETV("timeCreated", time);
		T_SETV("timeUpdated", time);
		T_SETV("intelSource", "unknown");
		*/
	} ENDMETHOD;

	// Gets called on client when this intel item is created. It should add itself to UI, map, other systems.
	/* virtual */ METHOD("clientAdd") {

	} ENDMETHOD;

	// Gets called on client when this intel item is updated. It should update data in UI, map, other systems.
	// You don't need to copy member variables here manually! They will be copied automatically by database methods.
	// Just update necessary data of map markers and other things if you need
	// _intelSrc - the source <Intel> item where values will be retrieved from
	/* virtual */ METHOD("clientUpdate") {
		params [P_THISOBJECT, P_OOP_OBJECT("_intelSrc")];
	} ENDMETHOD;

	// Gets called on client before this intel item is deleted. It should unregister itself from UI, map, other systems.
	/* virtual */ METHOD("clientRemove") {

	} ENDMETHOD;

ENDCLASS;

CLASS("IntelLocation", "Intel")

	VARIABLE("pos");
	VARIABLE("location");
	VARIABLE("unitData");
	VARIABLE("side");

	METHOD("new") {
		params ["_thisObject"];

		/*
		T_SETV("pos", [0 ARG 0 ARG 6]);
		T_SETV("unitData", []);
		T_SETV("location", "");
		T_SETV("side", sideUnknown);
		*/
	} ENDMETHOD;

ENDCLASS;
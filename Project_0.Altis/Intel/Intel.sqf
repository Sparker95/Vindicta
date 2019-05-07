#include "..\OOP_Light\OOP_Light.h"

/*
Classes of intel items
Author: Sparker 05.05.2019
*/

CLASS("Intel", "")

	VARIABLE("timeCreated");
	VARIABLE("timeUpdated");
	VARIABLE("intelSource");
	VARIABLE("source"); // Ref to the source intel item

	METHOD("new") {
		params ["_thisObject"];
		T_SETV("timeCreated", time);
		T_SETV("timeUpdated", time);
		T_SETV("intelSource", "unknown");
	} ENDMETHOD;

ENDCLASS;

CLASS("IntelLocation", "Intel")

	VARIABLE("pos");
	VARIABLE("location");
	VARIABLE("unitData");
	VARIABLE("side");

	METHOD("new") {
		params ["_thisObject"];

		T_SETV("pos", [0 ARG 0 ARG 6]);
		T_SETV("unitData", []);
		T_SETV("location", "");
		T_SETV("side", sideUnknown);
	} ENDMETHOD;

ENDCLASS;
#include "OOP_Light.h"

CLASS("ClassA", "")

	VARIABLE_ATTR("var", [ATTR_PRIVATE]);

	METHOD("new") {
		params ["_thisObject"];

		T_SETV("var", 123);
	} ENDMETHOD;

	METHOD("delete") {

	} ENDMETHOD;

ENDCLASS;

CLASS("ClassB", "")

	VARIABLE_ATTR("var", [ATTR_PRIVATE]);

	METHOD("new") {
		params ["_thisObject"];

		T_SETV("var", 123);
	} ENDMETHOD;

	METHOD("delete") {

	} ENDMETHOD;

	METHOD("illegalAccess") {
		params ["_thisObject", "_anotherObject"];

		SETV(_anotherObject, "var", 654);
	} ENDMETHOD;

ENDCLASS;


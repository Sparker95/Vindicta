#include "common.hpp"

/*
Base AI class for all unit-level bots (vehicles and infantry and civilians)

Author: Sparker
*/

#define pr private

#define OOP_CLASS_NAME AIUnit
CLASS("AIUnit", "AI_GOAP")

	// Object handle of the unit
	VARIABLE("hO");

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_agent")];

		// Set variables
		pr _hO = CALLM0(_agent, "getObjectHandle");
		T_SETV("hO", _hO);

		_hO setVariable [AI_UNIT_VAR_NAME, _thisObject];

	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];
		pr _hO = T_GETV("hO");
		_hO setVariable [AI_UNIT_VAR_NAME, nil];
	ENDMETHOD;

ENDCLASS;

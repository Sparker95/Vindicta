#include "common.hpp"

CLASS("ActionUnitDialogue", "ActionUnit")

	// Target object handle to talk to
	VARIABLE("target");

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI")];
	ENDMETHOD;

	METHOD(getDebugUIVariableNames)
		["target"]
	ENDMETHOD;

ENDCLASS;
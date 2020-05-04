#include "..\common.h"

/*
OOP class for one civilian.
First create a civilian unit/agent, then create this object and attach it to this unit.
*/

#define pr private

#define OOP_CLASS_NAME Civilian
CLASS("Civilian", "GOAP_Agent")

	VARIABLE("hO");
	VARIABLE("AI");

	METHOD(new)
		params [P_THISOBJECT, P_OBJECT("_civObjectHandle")];
		T_SETV("hO", _civObjectHandle);

		// Create AI
		//pr _AI = NEW("AIUnitCivilian", [_thisObject]);
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];
		//DELETE(T_GETV("AI"));

		deleteVehicle T_GETV("hO");
	ENDMETHOD;

	/* override */ METHOD(getAI)
		params [P_THISOBJECT];
		T_GETV("AI")
	ENDMETHOD;

	/* override */ METHOD(getSubagents)
		params [P_THISOBJECT];
		[]
	ENDMETHOD;

	METHOD(getObjectHandle)
		params [P_THISOBJECT];
		T_GETV("hO")
	ENDMETHOD;

ENDCLASS;
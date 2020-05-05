#include "common.h"

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

		OOP_INFO_1("NEW: %1", _civObjectHandle);

		if (isNull _civObjectHandle) then {
			OOP_ERROR_0("Passed object handle is null!");
		};

		T_SETV("hO", _civObjectHandle);

		// Create AI
		pr _AI = NEW("AIUnitCivilian", [_thisObject]);
		T_SETV("AI", _AI);
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		OOP_INFO_0("DELETE");

		DELETE(T_GETV("AI"));

		pr _hO = T_GETV("hO");
		deleteVehicle _hO;
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
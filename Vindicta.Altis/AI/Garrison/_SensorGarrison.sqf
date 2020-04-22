#include "..\..\OOP_Light\OOP_Light.h"

/*
Garrison sensor base class.
Saves some common variables at construction.
*/

#define pr private

CLASS("SensorGarrison", "Sensor")

	VARIABLE("gar"); // Garrison
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI")];
		pr _g = GETV(_AI, "agent");
		T_SETV("gar", _g);
	} ENDMETHOD;

ENDCLASS;
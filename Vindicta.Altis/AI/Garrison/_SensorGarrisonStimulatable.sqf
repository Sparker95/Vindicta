#include "..\..\OOP_Light\OOP_Light.h"

/*
Garrison stimulatable sensor base class.
Saves some common variables at construction.
*/

#define pr private

CLASS("SensorGarrisonStimulatable", "SensorStimulatable")

	VARIABLE("gar"); // Group handle
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI")];
		pr _g = GETV(_AI, "agent");
		T_SETV("gar", _g);
	} ENDMETHOD;

ENDCLASS;
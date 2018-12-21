#include "..\..\OOP_Light\OOP_Light.h"

/*
Garrison sensor base class.
Saves some common variables at construction.
*/

#define pr private

CLASS("SensorGroup", "Sensor")

	VARIABLE("gar"); // Group handle
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]]];
		pr _g = GETV(_AI, "agent");
		SETV(_thisObject, "gar", _g);
	} ENDMETHOD;

ENDCLASS;
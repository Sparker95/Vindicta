#include "common.hpp"

/*
Group stimulatable sensor base class.
Saves some common variables at construction.
*/

#define pr private

#define OOP_CLASS_NAME SensorGroupStimulatable
CLASS("SensorGroupStimulatable", "SensorStimulatable")

	VARIABLE("hG"); // Group handle
	VARIABLE("group"); // Group
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI")];
		pr _g = GETV(_AI, "agent");
		T_SETV("group", _g);
		pr _gh = CALLM0(_g, "getGroupHandle");
		T_SETV("hG", _gh);
	ENDMETHOD;

ENDCLASS;
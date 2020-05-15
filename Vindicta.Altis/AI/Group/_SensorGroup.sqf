#include "common.hpp"

/*
Group sensor base class.
Saves some common variables at construction.
*/

#define pr private

#define OOP_CLASS_NAME SensorGroup
CLASS("SensorGroup", "Sensor")

	VARIABLE("hG"); // Group handle
	VARIABLE("group"); // Group
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI")];
		
		ASSERT_OBJECT_CLASS(_AI, "AIGroup");
		
		pr _g = GETV(_AI, "agent");
		T_SETV("group", _g);
		pr _gh = CALLM0(_g, "getGroupHandle");
		T_SETV("hG", _gh);
	ENDMETHOD;

ENDCLASS;
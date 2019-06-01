#include "common.hpp"

// A simple mission that is created and destroyed when a location is created and destroyed.
CLASS("AmbientMission", "")
	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
	} ENDMETHOD;

	METHOD("update") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
	} ENDMETHOD;
ENDCLASS;
#include "common.hpp"

CLASS("CivilWarGameMode", "GameModeBase")

	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("name", "expand");
		T_SETV("spawningEnabled", false);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

	} ENDMETHOD;
		
	/* protected virtual */ METHOD("getLocationOwner") {
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
		OOP_DEBUG_MSG("%1", [_loc]);
		if(GETV(_loc, "type") == LOCATION_TYPE_BASE) then {
			GETV(_loc, "side") 
		} else {
			CIVILIAN
		}
	} ENDMETHOD;
ENDCLASS;

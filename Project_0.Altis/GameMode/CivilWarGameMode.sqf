#include "common.hpp"

/*
Design documentation:
https://docs.google.com/document/d/1DeFhqNpsT49aIXdgI70GI3GIR95LR2NnJ5cpAYYl3hE/edit#bookmark=id.ev4wu6mmqtgf
*/

CLASS("CivilWarGameMode", "GameModeBase")

	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("name", "CivilWar");
		T_SETV("spawningEnabled", false);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected virtual */ METHOD("getLocationOwner") {
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
		OOP_DEBUG_MSG("%1", [_loc]);
		private _type = GETV(_loc, "type");
		if(_type == LOCATION_TYPE_BASE or _type == LOCATION_TYPE_POLICE_STATION) then {
			GETV(_loc, "side") 
		} else {
			CIVILIAN
		}
	} ENDMETHOD;
ENDCLASS;

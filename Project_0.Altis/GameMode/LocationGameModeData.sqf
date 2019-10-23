#include "common.hpp"

/*
Class: GameMode.LocationGameModeData
Base class of objects assigned as Location.gameModeData
*/

CLASS("LocationGameModeData", "MessageReceiverEx")

	VARIABLE("location");

	// 
	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_location")];
		T_SETV("location", _location);
	} ENDMETHOD;

	// Meant to do processing and enable/disable respawn at this place based on different rules
	/* virtual */ METHOD("updatePlayerRespawn") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	METHOD("getMessageLoop") {
		gMessageLoopGameMode
	} ENDMETHOD;

ENDCLASS;

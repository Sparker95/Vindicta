#include "common.hpp"


// A base class for simple missions that are only active when a location is spawned. 
// They should be created in GameMode.locationSpawned and deleted in GameMode.locationDespawned.
CLASS("AmbientMission", "")
	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
	} ENDMETHOD;

	METHOD("update") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
	} ENDMETHOD;
ENDCLASS;
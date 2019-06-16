#include "common.hpp"


// A base class for simple missions that are only active when a location is spawned. 
// They should be created in GameMode.locationSpawned and deleted in GameMode.locationDespawned.
CLASS("AmbientMission", "")
	VARIABLE("states");

	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city"), P_ARRAY("_states")];
		T_SETV("states", _states);
	} ENDMETHOD;

	METHOD("isActive") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		T_PRVAR(states);
		private _cityData = GETV(_city, "gameModeData");
		GETV(_cityData, "state") in _states
	} ENDMETHOD;
	
	METHOD("update") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];

		private _active = T_CALLM("isActive", [_city]);
		T_CALLM("updateExisting", [_city ARG _active]);

		if(_active) then {
			T_CALLM("spawnNew", [_city]);
		}
	} ENDMETHOD;

	/* protected virtual */ METHOD("updateExisting") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
	} ENDMETHOD;

	/* protected virtual */ METHOD("spawnNew") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
	} ENDMETHOD;
	
ENDCLASS;
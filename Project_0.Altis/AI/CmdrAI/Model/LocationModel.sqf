#include "..\..\..\OOP_Light\OOP_Light.h"

// Collection of unitCount/vehCount and their orders
CLASS("LocationModel", "ModelBase")
	// Location position
	VARIABLE("pos");
	// Side considered to be owning this location
	VARIABLE("side");
	// Model Id of the garrison currently occupying this location
	VARIABLE("garrisonId");
	// Is this location a spawn?
	VARIABLE("spawn");
	// Is this location determined by the cmdr as a staging outpost?
	// (i.e. Planned attacks will be mounted from here)
	VARIABLE("staging");

	METHOD("new") {
		params [P_THISOBJECT, P_STRING("_ownerState"), P_STRING("_realObject")];
		T_SETV("pos", []);
		T_SETV("side", objNull);
		T_SETV("garrisonId", -1);
		T_SETV("spawn", false);
		T_SETV("staging", false);
	} ENDMETHOD;

	METHOD("setId") {
		params [P_THISOBJECT, P_NUMBER("_id")];
		T_SETV("id", _id);
	} ENDMETHOD;
	
	METHOD("sync") {
		params [P_THISOBJECT];

		T_PRVAR(realObject);
		// If we have an assigned Reak Object then sync from it
		if(_realObject isEqualType "") then {
			OOP_DEBUG_1("Updating LocationModel from Location %1", _realObject);
			T_SETV("pos", CALLM(_realObject, "getPos", []));
			T_SETV("side", CALLM(_realObject, "getSide", []));
		};
	} ENDMETHOD;
ENDCLASS;
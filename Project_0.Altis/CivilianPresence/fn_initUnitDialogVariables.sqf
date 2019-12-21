#include "CivilianPresence.hpp"
#include "..\OOP_Light\OOP_Light.h"

// Initializes stuff unit knows about, willing to talk about, and other variables related to dialogs

#define pr private

params ["_unit"];

// Is talking
_unit setVariable [CP_VAR_IS_TALKING, false, true]; // Broadcast that to everyone

// Known locations
private _locs = CALLSM0("Location", "getAll");
private _locsNear = _locs select {
	pr _type = CALLM0(_x, "getType");
	(CALLM0(_x, "getPos") distance player < 3000) &&
	(_type != LOCATION_TYPE_CITY) &&
	((random 10 < 3) || _type == LOCATION_TYPE_POLICE_STATION) // Civilian doesn't know about everything, but surely knows about police stations
};
_unit setVariable [CP_VAR_KNOWN_LOCATIONS, _locsNear, true]; // Broadcast that to everyone

// Agitated
_unit setVariable [CP_VAR_AGITATED, false, true]; // Broadcast that to everyone

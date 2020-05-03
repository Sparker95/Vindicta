#include "common.hpp"
#include "..\common.h"

// Initializes stuff unit knows about, willing to talk about, and other variables related to dialogs

#define pr private

params ["_unit"];

// Is talking
_unit setVariable [CP_VAR_IS_TALKING, false, true]; // Broadcast that to everyone

// Known locations
private _locs = CALLSM0("Location", "getAll");
private _locsNear = _locs select {
	pr _type = CALLM0(_x, "getType");
	pr _dist = CALLM0(_x, "getPos") distance _unit;
	(_dist < 3500) &&
	(_type != LOCATION_TYPE_CITY)
};

_locsCivKnows = _locsNear select {
	pr _type = CALLM0(_x, "getType");
	pr _dist = CALLM0(_x, "getPos") distance _unit;
	// Civilian can't tell about everything, but they surely know about police stations and locations which are very close
	(random 10 < 5) ||
	(_type == LOCATION_TYPE_POLICE_STATION) ||
	{_dist < 800} // If it's very close, civilians will surely tell about it
};

//diag_log format ["Locs known to civ: %1", _locsCivKnows];

_unit setVariable [CP_VAR_KNOWN_LOCATIONS, _locsCivKnows, true]; // Broadcast that to everyone

// Agitated
_unit setVariable [CP_VAR_AGITATED, false, true]; // Broadcast that to everyone

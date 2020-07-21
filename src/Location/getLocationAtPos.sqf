#include "Location.hpp"
#include "..\common.h"

// Class: Location
/*
Method: (static)getLocationAtPos
Returns a lowermost location that has the provided position/object within its border.

Parameters: _pos

_pos - position or object

Returns: <Location> or "" if there is no such location

Author: Sparker 2.11.2019
*/

#define pr private

params [P_THISCLASS, ["_pos", [], [objNull, []]]];

pr _locsToCheck = (nearestLocations  [_pos, ["vin_location"], LOCATION_BOUNDING_RADIUS_MAX]) apply {
	GET_LOCATION_FROM_HELPER_OBJECT(_x);
};

pr _locsParentCount = _locsToCheck select {
	_pos inArea GETV(_x, "border")
} apply {
	private _lvl = 0;
	private _parent = GETV(_x, "parent");
	while {!IS_NULL_OBJECT(_parent)} do {
		_parent = GETV(_parent, "parent");
		_lvl = _lvl + 1;
	};
	[_lvl, _x]
};

// Sort by the amount of parents
_locsParentCount sort false; // Descending

if (count _locsParentCount > 0) then {
	_locsParentCount#0#1
} else {
	""
};
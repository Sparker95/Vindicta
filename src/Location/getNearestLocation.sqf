#include "Location.hpp"
#include "..\common.h"

// Class: Location
/*
Method: (static)getNearestLocation
Returns the nearest location to given position(or object) and 2D distance to it

Parameters: _pos

_pos - position or object

Returns: [Location, distance]

Author: Sparker 2.11.2019
*/

#define pr private

params [P_THISCLASS, ["_pos", [], [objNull, []]]];

pr _all = (nearestLocations  [_pos, ["vin_location"], LOCATION_BOUNDING_RADIUS_MAX]) apply {
	GET_LOCATION_FROM_HELPER_OBJECT(_x);
};

pr _nearestLoc = _all select 0;
pr _smallestDist = GETV(_nearestLoc, "pos") distance2D _pos;

{
	pr _locPos = GETV(_x, "pos");
	pr _dist = _locPos distance2D _pos;
	if (_dist < _smallestDist) then {
		_nearestLoc = _x;
		_smallestDist = _dist;
	};
} forEach _all;

[_nearestLoc, _smallestDist]
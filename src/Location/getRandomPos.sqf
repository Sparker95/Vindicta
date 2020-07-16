#include "..\common.h"
#include "Location.hpp"

// Class: Location
/*
Method: getRandomPos
Returns a random position within the border of the location.
Distribution is uniform

Returns: Array, position
*/

#define pr private

params [P_THISOBJECT];

pr _border = T_GETV("border");
pr _pos = T_GETV("pos");

pr _r = T_GETV("boundingRadius");
pr _return = [0, 0, 0];
while {!(T_CALLM1("isInBorder", _return))} do {
	_return = _pos vectorAdd [-_r + (random (2*_r)), -_r + (random (2*_r)), 0];
};

_return
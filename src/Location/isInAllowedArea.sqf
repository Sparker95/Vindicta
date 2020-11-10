#include "..\common.h"
#include "Location.hpp"
// Class: Location
/*
Method: isInAllowedArea
Checks if given position is in one of the allowed areas

Parameters: _pos

_pos - position or object

Returns: nil
*/

#define pr private

params [P_THISOBJECT, ["_pos", objNull, [objNull, []]]];

pr _type = T_GETV("type");

// We can be at city obviously
if (_type == LOCATION_TYPE_CITY) exitWith { true };

// We can only be on road if at the roadblock
// Or not far away from it
if (_type == LOCATION_TYPE_ROADBLOCK) exitWith {
	(isOnRoad _pos) || (count (_pos nearRoads 8) > 0)
};

// If this is not built, we are allowed to be here
if (!T_GETV("isBuilt")) exitWith {
	true;
};

pr _areas = T_GETV("allowedAreas");

pr _index = _areas findIf {
	_x params ["_center", "_a", "_b", "_angle"];
	_pos inArea [_center, _a, _b, _angle, true]
};

_index != -1
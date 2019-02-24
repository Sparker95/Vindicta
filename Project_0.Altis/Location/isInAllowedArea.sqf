#include "..\OOP_Light\OOP_Light.h"

// Class: Location
/*
Method: isInAllowedArea
Checks if given position is in one of the allowed areas

Parameters: _pos

_pos - position or object

Returns: nil
*/

#define pr private

params [ ["_thisObject", "", [""]], ["_pos", objNull, [objNull, []]]];

pr _areas = T_GETV("allowedAreas");

pr _index = _areas findIf {
	_x params ["_center", "_a", "_b", "_angle"];
	_pos inArea [_center, _a, _b, _angle, true]
};

_index != -1
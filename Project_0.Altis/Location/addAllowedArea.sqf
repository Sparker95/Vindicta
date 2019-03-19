#define OOP_INFO
#include "..\OOP_Light\OOP_Light.h"

// Class: Location
/*
Method: addAllowedArea
Adds a rectangular allowed area to this location

Arguments:
_pos, _a, _b, _dir

_pos - position of the allowed area
_a, _b, _dir - size and direction, like in a marker

Returns: nil
*/

#define pr private

params [["_thisObject", "", [""]], ["_pos", [], [[]]], ["_a", 0, [0]], ["_b", 0, [0]], ["_dir", 0, [0]]];

pr _areas = T_GETV("allowedAreas");
_areas pushBack [_pos, _a, _b, _dir];
SET_VAR_PUBLIC(_thisObject, "allowedAreas", _areas);

nil

#include "..\common.h"

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

params [P_THISOBJECT, P_ARRAY("_pos"), P_NUMBER("_a"), P_NUMBER("_b"), P_NUMBER("_dir")];

OOP_INFO_4("ADD ALLOWED AREA: %1, %2, %3, %4", _pos, _a, _b, _dir);

pr _areas = T_GETV("allowedAreas");

_areas pushBack [_pos, _a, _b, _dir];

T_SETV_PUBLIC("allowedAreas", _areas);

nil
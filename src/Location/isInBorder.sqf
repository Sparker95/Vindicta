#include "..\common.h"

// Class: Location
/*
Method: isInBorder
Checks if given position is in area of given location.

Parameters: _pos

_pos - position

Returns: nil
*/

ASP_SCOPE_START(Location_fnc_isInBorder);
params [P_THISOBJECT, ["_pos", objNull, [objNull, []]]];

_pos inArea T_GETV("border")
#include "..\OOP_Light\OOP_Light.h"

// Class: Location
/*
Method: isInBorder
Checks if given position is in area of given location.

Parameters: _pos

_pos - position

Returns: nil
*/

params [ ["_thisObject", "", [""]], ["_pos", objNull, [objNull, []]]];

_pos inArea T_GETV("border")
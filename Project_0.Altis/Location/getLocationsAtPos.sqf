#include "..\OOP_Light\OOP_Light.h"

// Class: Location
/*
Method: (static)getLocationsAtPos
Returns an array of locations that have the provided position/object within its border. 
Same as getLocationAtPos, but returns all locations

Parameters: _pos

_pos - position or object

Returns: <Location> or "" if there is no such location

Author: Sparker 08 June 2019
*/

#define pr private

params [ ["_thisClass", "", [""]], ["_pos", [], [objNull, []]]];

GETSV("Location", "all") select {
	_pos inArea GETV(_x, "border")
}
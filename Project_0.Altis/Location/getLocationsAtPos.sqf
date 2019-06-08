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

pr _all = GETSV("Location", "all");

_all select {
	pr _locPos = GETV(_x, "pos");
	pr _br = GETV(_x, "boundingRadius");
	pr _ret = false;
	if ((_locPos distance2D _pos) < _br) then {
		_ret = CALLM1(_x, "isInBorder", _pos);
	};
	_ret
}
#include "..\OOP_Light\OOP_Light.h"

// Class: Location
/*
Method: (static)getLocationAtPos
Returns location that has the provided position/object within its border. 

Parameters: _pos

_pos - position or object

Returns: <Location> or "" if there is no such location

Author: Sparker 2.11.2019
*/

#define pr private

params [ ["_thisClass", "", [""]], ["_pos", [], [objNull, []]]];

pr _all = GETSV("Location", "all");

pr _index = _all findIf {
	pr _locPos = GETV(_x, "pos");
	pr _br = GETV(_x, "boundingRadius");
	pr _ret = false;
	if ((_locPos distance2D _pos) < _br) then {
		_ret = CALLM1(_x, "isInBorder", _pos);
	};
	_ret
};

if (_index != -1) then {
	_all select _index
} else {
	""
};
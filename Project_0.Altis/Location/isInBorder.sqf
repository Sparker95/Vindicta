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

private _border = GET_VAR(_thisObject, "border");
private _locPos = GET_VAR(_thisObject, "pos");

if (_border isEqualType 0) then {
	// Border has circular shape
	(_locPos distance2D _pos) < _border
} else {
	// Border has rectangular shape
	_pos inArea [_locPos, _border select 0, _border select 1, _border select 2, true];
};
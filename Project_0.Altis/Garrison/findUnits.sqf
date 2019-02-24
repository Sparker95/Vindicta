#include "common.hpp"
#include "..\OOP_Light\OOP_Light.h"

//Class: Garrison
/*
Method: findUnits
Returns an array of units with specified category and subcategory

Parameters: _query

_query - array of [_catID, _subcatID].
_subcatID can be -1 if you don't care about a subcategory match.

Returns: Array of units <Unit> class
*/

#define pr private

params [["_thisObject", "", [""]], ["_query", "", [[]]] ];

pr _return = [];
pr _units = GETV(_thisObject, "units");
{ // for each _query
	_x params ["_catID", "_subcatID"];
	{ // for each _units
		pr _unit = _x;
		pr _mainData = CALLM(_unit, "getMainData", []);
		_mainData params ["_catIDx", "_subcatIDx"];
		if (_catIDx == _catID && (_subcatIDx == _subcatID || _subcatID == -1)) then { _return pushBack _unit; };
	} forEach _units;
} forEach _query;

_return
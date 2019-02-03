#include "..\OOP_Light\OOP_Light.h"

//Class: Garrison
/*
Method: countUnits
Counts amount of units with specified category and subcategory

Parameters: _query

_query - array of [_catID, _subcatID].
_subcatID can be -1 if you don't care about a subcategory match.

Returns: Array of units <Unit> class
*/

// Todo: optimize this

#define pr private

params [["_thisObject", "", [""]], ["_query", "", [[]]] ];

pr _units = CALLM1(_thisObject, "findUnits", _query);
count _units
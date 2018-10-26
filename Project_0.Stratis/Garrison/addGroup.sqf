/*
Adds an existing group to this garrison
*/

//#include "..\Garrison\Garrison.hpp"
#include "..\Message\Message.hpp"
#include "..\OOP_Light\OOP_Light.h"

params[["_thisObject", "", [""]], ["_group", "", [""]] ];

// Check if the group is already in another garrison
private _groupGarrison = CALL_METHOD(_group, "getGarrison", []);
if (_groupGarrison != "") exitWith {
	diag_log format ["[Garrison::addGroup] Error: can't add a group which is already in a garrison, garrison: %1, group: %2",
		GET_VAR(_thisObject, "debugName"), _group];
};

private _groupUnits = CALL_METHOD(_group, "getUnits", []);
private _units = GET_VAR(_thisObject, "units");

{
	private _unit = _x;
	_units pushBack _unit;
} forEach _groupUnits;

private _groups = GET_VAR(_thisObject, "groups");
_groups pushBack _group;
CALL_METHOD(_group, "setGarrison", [_thisObject]);


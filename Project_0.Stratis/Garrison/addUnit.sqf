/*
Adds an existing unit to this garrison
*/

#include "..\Garrison\Garrison.hpp"
#include "..\Message\Message.hpp"
#include "..\OOP_Light\OOP_Light.h"

params[["_thisObject", "", [""]], ["_unit", [], [[]]] ];

// Check if the unit is already in a garrison
private _unitGarrison = CALL_METHOD(_unit, "getGarrison", []);
if(_unitGarrison != "") exitWith {
	diag_log format ["[Garrison::addUnit] Error: can't add a unit which is already in a garrison: %1: %2", _unit, CALL_METHOD(_unit, "getDebugData", [])];
};

// Check if the unit is in a group
private _unitGroup = CALL_METHOD(_unit, "getGroup", []);
if (_unitGroup != "") exitWith {
	diag_log format ["[Garrison::addUnit] Error: can't add a unit which has a group: %1: %2", _unit, CALL_METHOD(_unit, "getDebugData", [])];
};

private _units = GET_VAR(_thisObject, "units");
_units pushBack _unit;
CALL_METHOD(_unit, "setGarrison", [_thisObject]);


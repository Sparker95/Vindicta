#include "..\Message\Message.hpp"
#include "..\OOP_Light\OOP_Light.h"
//#include "..\Garrison\Garrison.hpp"

// Class: Garrison
/*
Method: addUnit
Adds an existing unit to this garrison. Unit can only be added while not in a group. So, only vehicles can be added this way.

Threading: should be called through postMethod (see <MessageReceiverEx>)

Parameters: _unit

_unit - <Unit> object

Returns: nil
*/

params[["_thisObject", "", [""]], ["_unit", "", [""]] ];

// Check if the unit is already in a garrison
private _unitGarrison = CALL_METHOD(_unit, "getGarrison", []);
if(_unitGarrison != "") exitWith {
	diag_log format ["[Garrison::addUnit] Error: can't add a unit which is already in a garrison, garrison: %1, unit: %2: %3",
		GET_VAR(_thisObject, "debugName"), _unit, CALL_METHOD(_unit, "getData", [])];
};

// Check if the unit is in a group
private _unitGroup = CALL_METHOD(_unit, "getGroup", []);
if (_unitGroup != "") exitWith {
	diag_log format ["[Garrison::addUnit] Error: can't add a unit assigned to a group, garrison : %1, unit: %2: %3",
		GET_VAR(_thisObject, "debugName"), _unit, CALL_METHOD(_unit, "getData", [])];
};

private _units = GET_VAR(_thisObject, "units");
_units pushBack _unit;
CALL_METHOD(_unit, "setGarrison", [_thisObject]);
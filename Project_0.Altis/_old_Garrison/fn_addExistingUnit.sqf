/*
Used to add an existing unit to garrison when moving a unit from one garrison to another.
Normally units should only be transfered in groups, but we have vehicles as an exclusion.

_unitFullData structure:
[_catID, _subcatID, _class, _objectHandle, _destGroupID]
_objectHandle is _objNull for not spawned units.

Parameters:
	_returnArray - the array where the unit's new unitData will be after the request has been executed
*/

#include "garrison.hpp"

params ["_lo", "_unitFullData", ["_returnArray", []], ["_debug", true]];

private _queue = _lo getVariable ["g_threadQueue", []];
_queue pushBack [G_R_ADD_EXISTING_UNIT, _unitFullData, _returnArray];

private _hThread = _lo getVariable ["g_threadHandle", scriptNull];
if(_hThread isEqualTo scriptNull) then //If the thread isn't running, start it
{
	[_lo, 10, true] call gar_fnc_startThread;
};

//Return value - request ID
private _rID = _lo getVariable ["g_assignRequestID", 0];
_lo setVariable ["g_assignRequestID", _rID+1];
_rID

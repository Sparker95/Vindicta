/*
Used to add an existing group to garrison when moving a group from one garrison to another. This function shouldn't be accessed publicly. If you want to move a group between garrisons, use fn_moveGroup.

_unitsFullData - array of:
	[_catID, _subcatID, _classID, _objectHandle]

_groupData is structured like in g_groups
*/

#include "garrison.hpp"

params ["_lo", "_unitsFullData", "_groupData", ["_returnArray", []], ["_debug", true]];

private _queue = _lo getVariable ["g_threadQueue", []];
_queue pushBack [G_R_ADD_EXISTING_GROUP, [_unitsFullData, _groupData], _returnArray];

private _hThread = _lo getVariable ["g_threadHandle", nil];
if(_hThread isEqualTo scriptNull) then //If the thread isn't running, start it
{
	[_lo, 10, true] call gar_fnc_startThread;
};

//Return value - request ID
private _rID = _lo getVariable ["g_assignRequestID", 0];
_lo setVariable ["g_assignRequestID", _rID+1];
_rID
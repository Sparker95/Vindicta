/*
Used to move a group from one garrison to another.

_returnArray - the groupID of the new group will be written here.
*/

#include "garrison.hpp"

params ["_lo_src", "_lo_dst", "_groupID", ["_returnArray", []], ["_debug", true]];

//Add it to the queue
private _queue = _lo_src getVariable ["g_threadQueue", []];
_queue pushBack [G_R_MOVE_GROUP, [_lo_dst, _groupID], _returnArray];

private _hThread = _lo_src getVariable ["g_threadHandle", scriptNull];
if(_hThread isEqualTo scriptNull) then //If the thread isn't running, start it
{
	[_lo_src, 10, true] call gar_fnc_startThread;
};

//Return value - request ID
private _rID = _lo_src getVariable ["g_assignRequestID", 0];
_lo_src setVariable ["g_assignRequestID", _rID+1];
_rID

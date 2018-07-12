/*
Used to add an empty group to the garrison.
_returnArray - the array where the new group's ID will be returned to.
*/

#include "garrison.hpp"

params ["_lo", "_groupType", "_returnArray", ["_debug", true]];

//diag_log format ["types with crew: %1", _typesWithCrew];

//Add a request with empty array to the queue
private _queue = _lo getVariable ["g_threadQueue", []];
_queue pushBack [G_R_ADD_NEW_GROUP, [[], _groupType], _returnArray];

private _hThread = _lo getVariable ["g_threadHandle", scriptNull];
if(_hThread isEqualTo scriptNull) then //If the thread isn't running, start it
{
	[_lo, 10, true] call gar_fnc_startThread;
};

//Return value - request ID
private _rID = _lo getVariable ["g_assignRequestID", 0];
_lo setVariable ["g_assignRequestID", _rID+1];
_rID

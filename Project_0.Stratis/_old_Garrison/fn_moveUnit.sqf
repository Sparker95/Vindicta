/*
Used to move a unit between two garrisons.

Parameters:
	_returnArray - to this array the unit's unitData will be written after moving the unit
*/

#include "garrison.hpp"

params ["_lo_src", "_lo_dst", "_unitData", "_destGroupID", ["_debug", true]];

//Add it to the queue
private _queue = _lo_src getVariable ["g_threadQueue", []];
private _requestData = [_lo_dst, _unitData, _destGroupID];
_queue pushBack [G_R_MOVE_UNIT, _requestData];


private _hThread = _lo_src getVariable ["g_threadHandle", scriptNull];
if(_hThread isEqualTo scriptNull) then //If the thread isn't running, start it
{
	[_lo_src, 10, true] call gar_fnc_startThread;
};

//Return value - request ID
private _rID = _lo_src getVariable ["g_assignRequestID", 0];
_lo_src setVariable ["g_assignRequestID", _rID+1];
_rID

/*
Used to move a unit between two garrisons. Garrisons' states don't matter, unit's state will be set according to the destination garrison
*/

#include "garrison.hpp"

params ["_lo_src", "_lo_dst", "_unitData", ["_debug", true]];

//Add it to the queue
private _queue = _lo_src getVariable ["g_threadQueue", []];
private _requestData = [_lo_dst, _unitData];
_queue pushBack [G_R_MOVE_UNIT, _requestData];


private _hThread = _lo getVariable ["g_threadHandle", scriptNull];
if(_hThread isEqualTo scriptNull) then //If the thread isn't running, start it
{
	[_lo, 10, true] call gar_fnc_startThread;
};

//Return value - request ID
private _rID = _lo getVariable ["g_assignRequestID", 0];
_lo setVariable ["g_assignRequestID", _rID+1];
_rID
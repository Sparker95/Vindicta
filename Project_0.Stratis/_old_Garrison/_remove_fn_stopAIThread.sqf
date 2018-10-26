/*
This functions stops any AI thread running for this garrison.
*/

#include "garrison.hpp"

params ["_lo"];

//Add it to the queue
private _queue = _lo getVariable ["g_threadQueue", []];
_queue pushBack [G_R_STOP_AI_SCRIPT];

private _hThread = _lo getVariable ["g_threadHandle", scriptNull];
if(_hThread isEqualTo scriptNull) then //If the thread isn't running, start it
{
	[_lo, 10, true] call gar_fnc_startThread;
};

//Return value - request ID
private _rID = _lo getVariable ["g_assignRequestID", 0];
_lo setVariable ["g_assignRequestID", _rID+1];
_rID

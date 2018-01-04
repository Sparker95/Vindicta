/*
Used to start a medium level AI script for this garrison.
If an AI script is already running, it will be stopped.
*/

params ["_lo", "_scriptName"];

#include "garrison.hpp"

//Add it to the queue
private _queue = _lo getVariable ["g_threadQueue", []];
_queue pushBack [G_R_START_AI_SCRIPT, _scriptName];

private _hThread = _lo getVariable ["g_threadHandle", nil];
if(_hThread isEqualTo scriptNull) then //If the thread isn't running, start it
{
	[_lo, 10, true] call gar_fnc_startThread;
};

//Return value - request ID
private _rID = _lo getVariable ["g_assignRequestID", 0];
_lo setVariable ["g_assignRequestID", _rID+1];
_rID
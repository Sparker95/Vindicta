/*
Puts a stop-request to the garrison thread queue
*/

#include "garrison.hpp"

params ["_lo", ["_debug", true]];

private _hThread = _lo getVariable ["g_threadHandle", scriptNull];
if(!(isNil "_hThread")) then
{
	private _queue = _lo getVariable ["g_threadQueue", []];
	_queue pushBack [G_R_STOP];
};

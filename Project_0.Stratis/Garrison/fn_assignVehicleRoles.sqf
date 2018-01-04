/*
This function assigns vehicles in specified group to units in the same group
*/

#include "garrison.hpp"

params ["_lo", "_groupID", "_assignDrivers", "_assignTurrets", "_assignPassengers"];

private _queue = _lo getVariable ["g_threadQueue", []];
_queue pushBack [G_R_ASSIGN_VEHICLE_ROLES, [_groupID, _assignDrivers, _assignTurrets, _assignPassengers]];

private _hThread = _lo getVariable ["g_threadHandle", nil];
if(_hThread isEqualTo scriptNull) then //If the thread isn't running, start it
{
	[_lo, 10, true] call gar_fnc_startThread;
};

//Return value - request ID
private _rID = _lo getVariable ["g_assignRequestID", 0];
_lo setVariable ["g_assignRequestID", _rID+1];
_rID
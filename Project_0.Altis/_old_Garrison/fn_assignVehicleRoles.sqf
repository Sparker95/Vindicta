/*
This function implements the standard vehicle role assignment for specified group of the garrison.
So, for all vehicles in the group there will be assigned drivers, gunners and passengers - if specified in parameters;
*/

#include "garrison.hpp"

params ["_lo", "_groupID", "_assignDrivers", "_assignTurrets", "_assignPassengers"];

private _queue = _lo getVariable ["g_threadQueue", []];
_queue pushBack [G_R_ASSIGN_VEHICLE_ROLES, [_groupID, _assignDrivers, _assignTurrets, _assignPassengers]];

private _hThread = _lo getVariable ["g_threadHandle", scriptNull];
if(_hThread isEqualTo scriptNull) then //If the thread isn't running, start it
{
	[_lo, 10, true] call gar_fnc_startThread;
};

//Return value - request ID
private _rID = _lo getVariable ["g_assignRequestID", 0];
_lo setVariable ["g_assignRequestID", _rID+1];
_rID

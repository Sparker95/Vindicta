/*
This function moves a unit from one group to another.

_unitData - the unitData of the unit
_groupID - the group ID of the group to join.
_keepOldStructure - keep the structure of the group which is being abandoned.
*/

#include "garrison.hpp"

params ["_lo", "_unitData", "_groupID", "_keepOldStructure"];

private _queue = _lo getVariable ["g_threadQueue", []];
_queue pushBack [G_R_JOIN_GROUP, [_unitData, _groupID, _keepOldStructure]];

private _hThread = _lo getVariable ["g_threadHandle", scriptNull];
if(_hThread isEqualTo scriptNull) then //If the thread isn't running, start it
{
	[_lo, 10, true] call gar_fnc_startThread;
};

//Return value - request ID
private _rID = _lo getVariable ["g_assignRequestID", 0];
_lo setVariable ["g_assignRequestID", _rID+1];
_rID
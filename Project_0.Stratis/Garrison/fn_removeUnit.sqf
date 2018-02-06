/*
Removes the unit from garrison. Use it only when the unit is no longer associated with any garrison, for example when it's destroyed.

Used to push a "remove unit"-request to the garrison queue
Can be called on a _unitdata or on a unit

_unitData structure:
[_catID, _subcatID, _unitID]
*/

#include "garrison.hpp"

params ["_lo", "_unit_or_unitData", ["_debug", true]];

private _unitData = [];

if(typeName _unit_or_unitData isEqualTo "OBJECT") then
{
	_unitData = _unit_or_unitData getVariable ["g_unitData", []];
}
else
{
	_unitData = _unit_or_unitData;
};



private _queue = _lo getVariable ["g_threadQueue", []];
_queue pushBack [G_R_REMOVE_UNIT, _unitData];

private _hThread = _lo getVariable ["g_threadHandle", scriptNull];
if(_hThread isEqualTo scriptNull) then //If the thread isn't running, start it
{
	[_lo, 10, true] call gar_fnc_startThread;
};

//Return value - request ID
private _rID = _lo getVariable ["g_assignRequestID", 0];
_lo setVariable ["g_assignRequestID", _rID+1];
_rID
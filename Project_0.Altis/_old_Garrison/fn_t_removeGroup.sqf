/*
Used inside the thread to remove a group and all its units from the garrison.
*/

#include "garrison.hpp"

params ["_lo", "_groupID"];

private _groupData = [_lo, _groupID, 2] call gar_fnc_getGroup;
private _group = _groupData select 0;
private _groupIndex = _groupData select 1;

if(_groupIndex == -1) exitWith
{
	diag_log format ["fn_t_removeGroup.sqf: garrison: %1, specified group not found: %2", _lo getVariable ["g_name", ""], _groupID];
};

private _groupUnits = _group select 0;
private _unitData = [];
{
	_unitData = _x select 0; //Because each element in groupUnits is [unitData, vehicleRole]
	if(_unitData select 2 != -1) then //If the unit in the group hasn't been destroyed
	{
		[_lo, _unitData] call gar_fnc_t_removeUnit; //Remove it immediately
	};

} forEach _groupUnits;

//Delete the group from the array
private _groups = _lo getVariable ["g_groups", []];
_groups deleteAt _groupIndex;

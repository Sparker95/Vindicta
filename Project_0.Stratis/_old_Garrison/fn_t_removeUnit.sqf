/*
Used inside the garrison thread to remove unit from the garrison array
*/

#include "garrison.hpp"

params ["_lo", "_unitData", ["_debug", true]];

private _unitArrayAndIndex = [_lo, _unitData, 2] call gar_fnc_getUnit; //Get unit's array and [_subcat, _index]
private _unit = _unitArrayAndIndex select 0;
private _unitID = _unitData select 2;
private _subcat = _unitArrayAndIndex select 1 select 0;
private _i = _unitArrayAndIndex select 1 select 1;

if(_i == -1) exitWIth //Error: unit with this ID not found
{
	diag_log format ["fn_t_removeUnit.sqf: garrison: %1, unit not found: %2", _lo getVariable ["g_name", ""], _unitData];
};

_subcat deleteAt _i;

//if(_removeFromGroup) then
//{
	//Remove the unit from its group
private _groupID = _unit select 3;
if(_groupID != -1) then
{
	private _group = [_lo, _groupID] call gar_fnc_getGroup;
	if(_group isEqualTo []) exitWith //Error: group with this ID not found
	{
		diag_log format ["fn_t_removeUnit.sqf: garrison: %1, error: group not found: %2", _lo getVariable ["g_name", ""], _groupID];
	};

	//Find the unit in this group
	_i = 0;
	private _units = _group select 0;
	_count = count _units;
	while {_i < _count} do
	{
		_unit = (_units select _i) select 0;
		if (_unit select 2 == _unitID) exitWIth
		{
			_unit set [2, -1]; //-1 means the unit has been removed from this group
		};
		_i = _i + 1;
	};
};
//};

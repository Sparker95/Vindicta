/*
Used inside the garrison thread to move a group from one garrison to another.

Parameters:
	_lo - source garrison object
	_requestData: [_lo_dst, _groupID]
*/

#include "garrison.hpp"

params ["_lo", "_requestData"];

private _lo_dst = _requestData select 0;
private _groupID = _requestData select 1;
private _group = [_lo, _groupID] call gar_fnc_getGroup;

if(_group isEqualTo []) exitWIth
{
	diag_log format ["fn_t_moveGroup.sqf: garrison: %1, specified group not found: %2", _lo getVariable ["g_name", ""], _groupID];
};

//Fill the arguments
private _unitData = [];
private _unitsFullData = [];
private _groupUnits = _group select 0;
//diag_log format ["The units in this group are: %1", _groupUnits];
private _unit = [];
{
	_unitData = _x select 0;
	if(_unitData select 2 != -1) then //If the unit is alive
	{
		_unit = [_lo, _unitData, 0] call gar_fnc_getUnit;
		_unitsFullData pushback [_unitData select 0, _unitData select 1, _unit select 0, _unit select 1]; //[_catID, _subcatID, _class, _objectHandle]
	};
} forEach _groupUnits;

private _groupCopy = +_group;
//Remove the group from old garrison
[_lo, _groupID] call gar_fnc_t_removeGroup;

private _groupIDArray = [];
private _rID = [_lo_dst, _unitsFullData, _groupCopy, _groupIDArray] call gar_fnc_addExistingGroup; //Copy the old units because they will be modified by gar_fnc_t_removeGroup

waitUntil {[_lo_dst, _rID] call gar_fnc_requestDone};

//Return the group ID of the group in the new garrison
_groupIDArray select 0
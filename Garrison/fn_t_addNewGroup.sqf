/*
Used inside the thread to add a new group to the garrison.

_newGroupData is an array with units' [catID, subcatID, class]

Return value: _groupID - the ID of the new group
*/

params ["_lo", "_newGroupData", "_spawned", ["_debug", true]];

private _newGroupUnits = _newGroupData select 0;
private _newGroupType = _newGroupData select 1;
//Add the group to the groups array of the garrison
//Assign a group ID
private _groupID = _lo getVariable ["g_unitIDCounter", nil];
_lo setVariable ["g_unitIDCounter", _groupID + 1];
//Add the group to the array
private _groups = _lo getVariable ["g_groups", []];
_groups pushBack [[], grpNull, _groupID, _newGroupType]; //Units, groupHandle, groupID, groupType

//Add all the units in _newGroupData to the garrison
private _newUnitData = [];
{
	_newUnitData = _x + [_groupID];
	[_lo, _newUnitData, _spawned] call gar_fnc_t_addNewUnit;
} forEach _newGroupUnits;

//Assign vehicle roles
[_lo, _groupID, _spawned, true, true, false] call gar_fnc_t_assignVehicleRoles;

_groupID
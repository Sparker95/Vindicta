/*
This function moves a unit from one group to another. Call it only from inside of the garrison thread.

_keepStructure - bool.
	false - the record about unit in the old group will be removed.
	true - this record will be left in the old group.
*/

#include "garrison.hpp"

params ["_lo", "_requestData", "_spawned"];

private _unitData = _requestData select 0;
private _newGroupID = _requestData select 1;
private _keepStructure = _requestData select 2;

//Read the input
private _catID = _unitData select 0;
private _subcatID = _unitData select 1;
private _unitID = _unitData select 2;

//Get the unit's array
private _unit = [_lo, _unitData, 0] call gar_fnc_getUnit;
//diag_log format ["  unitData: %1 unit: %2", _unitData, _unit];
//Get the old group array
private _oldGroupID = _unit select G_UNIT_GROUP_ID;
private _oldGroup = [_lo, _oldGroupID, 0] call gar_fnc_getGroup;
//private _oldGroupIndex = _g select 1; //Index of the group in the group array, if we will need to delete the group
private _oldGroupUnits = if(_oldGroup isEqualTo []) then {[]} else {_oldGroup select G_GROUP_UNITS};

//Get the new group array
private _newGroup = [_lo, _newGroupID, 0] call gar_fnc_getGroup;
private _newGroupUnits = _newGroup select G_GROUP_UNITS;

//Change old group?
private _changeOldGroup = if(_oldGroupID == -1 && _catID == T_VEH) then {false} else {true};

if (((count _oldGroup) == 0 && _catID != T_VEH) || ((count _newGroup) == 0) || ((count _unit) == 0))
exitwith {
	diag_log format ["fn_t_joinGroup.sqf: garrison: %1, error: invalid unit/group structure", _lo getVariable ["g_name", "(error: no name)"]];
};

//Add unit to its new group
private _unitDataCopy = +_unitData;
_index = -1;
//Check if a vacant unit slot is available in the new group
{
	private _u = [_x select 0 select 0, _x select 0 select 1]; //[_catID, _subcatID]
	if ((_u isEqualTo [_catID, _subcatID]) && ((_x select 0 select 2) == -1)) exitWith {_index = _foreachindex};
} forEach _newGroupUnits;
if(_index == -1) then
{
	//Add the unit's data to the new group array
	/*
	if(_catID == T_VEH) then
	{
		_newGroupUnits = [_unitDataCopy, []] + _newGroupUnits; //Vehicles are added to the beginning of the array
		_newGroup set [G_GROUP_UNITS, _newGroupUnits];
	}
	else
	{*/
		_newGroupUnits pushBack [_unitDataCopy, []]; //[_unitData, _vehicleRole]
	//};
}
else
{
	//Set unit's ID to the found unit data
	((_newGroupUnits select _index) select 0) set  [2, _unitID];
};
_unit set [G_UNIT_GROUP_ID, _newGroupID];
if(_spawned) then //If spawned, make a unit actually join the group
{
	if(_catID != T_VEH) then
	{
		private _groupHandle = _newGroup select G_GROUP_HANDLE;
		private _unitHandle = _unit select G_UNIT_HANDLE;
		if(isNull _groupHandle) then
		{
			private _side = _lo getVariable ["g_side", WEST];
			_groupHandle = createGroup [_side, true];
			_newGroup set [G_GROUP_HANDLE, _groupHandle];
		};
		[_unitHandle] join _groupHandle;
		//todo assign vehicle roles
	};
};

//Remove unit from its old group
//diag_log format ["  old group: %1", _oldGroup];
//diag_log format ["  old group units: %1", _oldGroupUnits];
if(_changeOldGroup) then
{
	private _index = -1;
	private _found = false;
	{
		if ((_x select 0) isEqualTo _unitData) exitWith
		{
			_index = _foreachindex;
		};
	} forEach _oldGroupUnits;

	//If we can't find the unit in its old group
	if(_index == -1) exitWith
	{
		diag_log format ["fn_t_joinGroup.sqf: garrison: %1, error: unit not found in group array", _lo getVariable ["g_name", "(error: no name)"]];
	};

	if(_keepStructure) then
	{
		((_oldGroupUnits select _index) select 0) set  [2, -1]; //Set unitID to -1
	}
	else
	{
		_oldGroupUnits deleteAt _index; //Delete unit's data from group array
		//Check if the last unit was removed from original group
		//I think it's not needed
	};
};
/*
Used inside the thread to add an existing unit to a garrison.

_unitFullData structure:
[_catID, _subcatID, _class, _objectHandle, _groupID]
_objectHandle is _objNull for not spawned units.

Return value: new unit's ID
*/

#include "garrison.hpp"

params ["_lo", "_unitFullData", "_spawned", ["_debug", true]];

private _catID = _unitFullData select 0;
private _subcatID = _unitFullData select 1;
private _class = _unitFullData select 2;
private _objectHandle = _unitFullData select 3;
private _groupID = _unitFullData select 4;

private _template = _lo getVariable ["g_template", []];

//Check if unit's data is correct
/*
if(!([_template, _catID, _subcatID, _classID] call t_fnc_isValid)) exitWith {
	diag_log format ["fn_t_addExistingUnit.sqf: garrison: %1, error: wrong unit full data: %2", _lo getVariable ["g_name", ""], _unitFullData];
};
*/

//Check if the specified group exists
private _group = [];
if(_groupID != -1) then
{
	_group = [_lo, _groupID] call gar_fnc_getGroup;
	if(_group isEqualTo []) exitWith
	{
		diag_log format ["fn_t_addExistingUnit.sqf: garrison: %1, specified group not found: %2", _lo getVariable ["g_name", ""], _groupID];
	};
};

private _cat = [];
switch (_catID) do
{
	case T_INF: //Add infantry
	{
		_cat = _lo getVariable ["g_inf", []];
	};
	case T_VEH: //Add a vehicle
	{
		_cat = _lo getVariable ["g_veh", []];
	};
	case T_DRONE: //Add a drone
	{
		_cat = _lo getVariable ["g_drone", []];
	};
};

//Assign a unit's ID
private _unitID = _lo getVariable ["g_unitIDCounter", nil];
_lo setVariable ["g_unitIDCounter", _unitID + 1];

//Add the unit
private _subCat = _cat select _subcatID;
_subCat pushBack [_class, _objectHandle, _unitID, _groupID];

//Add the unit to its group if it has a group
if(_groupID != -1) then
{
	private _groupUnits = _group select G_GROUP_UNITS;
	_groupUnits pushBack [[_catID, _subcatID, _unitID], []]; //todo note that assigned vehicle array is lost
};

if(_spawned) then //If we are adding the unit to an already spawned garrison
{
	//If unit was not spawned at the moment of joining, spawn it
	if (_objectHandle isEqualTo objNull) then
	{
		[_lo, [0, 0, 0], [_catID, _subcatID, _unitID]] call gar_fnc_t_spawnUnit;
	}
	else //If the unit has been spawned already, assign its variables
	{
		//Set unit's variables
		_objectHandle setVariable ["g_garrison", _lo, false]; //The garrison this unit is assitiated with
		private _unitData = _objectHandle getVariable ["g_unitData", []];
		_unitData set [2, _unitID]; //Set unit's ID
	};
}
else //If we are adding unit to despawned garrison
{
	//If unit was spawned at the moment of adding, despawn it
	if (!(_objectHandle isEqualTo objNull)) then
	{
		[_lo, [_catID, _subcatID, _unitID]] call gar_fnc_t_despawnUnit;
	};
};

_unitID
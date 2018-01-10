/*
Used inside the thread to add a new unit to an idle(not spawned) garrison and also add it to the group.

_newUnitData is structured like this:
[catID, _subcatID, _class, _groupID]

Return value: _unitID - the ID of the new unit
*/

#include "garrison.hpp"

params ["_lo", "_newUnitData", "_spawned", ["_debug", true]];

private _catID = _newUnitData select 0;
private _subcatID = _newUnitData select 1;
private _class = _newUnitData select 2;
private _groupID = _newUnitData select 3;

//Find the group with this _groupID, if it's not -1
if(_groupID == -1 && _catID == T_INF) exitWith
{
	diag_log format ["fn_t_addNewUnit.sqf: garrison: %1, error: attempt to add a unit without group: %2", _lo getVariable ["g_name", ""], _newUnitData];
};

private _group = [];

if(_groupID != -1) then
{
	_group = [_lo, _groupID] call gar_fnc_getGroup;
};

if(_group isEqualTo [] && _groupID != -1) exitWIth
{
	diag_log format ["fn_t_addNewUnit.sqf: garrison: %1, error: specified group not found: %2", _lo getVariable ["g_name", ""], _newUnitData];
};


//If group is found, proceed with creating a new unit

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

//Add the unit to garrison
private _subCat = _cat select _subcatID;
//Assign a unit's ID
private _unitID = _lo getVariable ["g_unitIDCounter", nil];
_lo setVariable ["g_unitIDCounter", _unitID + 1];
//Finally add the unit's data to the array
_subCat pushBack [_class, objNull, _unitID, _groupID];

//Add the unit to its group
if(_groupID != -1) then
{
	private _groupUnits = _group select 0;
	_groupUnits pushBack [[_catID, _subcatID, _unitID], []]; //[_unitData, _vehicleRole]
};

//Do other things with the unit
//Like despawn it or something like that

if(_spawned) then //If we are adding the unit to an already spawned garrison
{
	//Spawn the unit
	[_lo, [0, 0, 0], [_catID, _subcatID, _unitID]] call gar_fnc_t_spawnUnit;
};

_unitID
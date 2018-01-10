/*
Used inside the thread to despawn units.
*/

#include "garrison.hpp"

params ["_lo"];

//Initialize some variables
private _catID = 0;
private _subcatID = 0;
private _cat = [];
private _subcat = [];
//private _class = "";
private _catSize = 0;
private _unit = [];
//private _pos = getPos player; //Temporary
private _objectHandle = objNull;
private _groups = _lo getVariable ["g_groups", []];

//Delete all soldiers
_catID = T_INF;
_cat = _lo getVariable ["g_inf", []];
_catSize = T_INF_SIZE;
_subCatID = 0;
while {_subCatID < _catSize} do
{
	_subCat = _cat select _subCatID;
	{
		_unit = _x;
		[_lo, [_catID, _subcatID, _unit select 2]] call gar_fnc_t_despawnUnit;
	} forEach _subCat;
	_subCatID = _subCatID + 1;
};

//Delete all created groups
private _group = [];
{
	_group = _x;
	deleteGroup (_group select 1);
	_group set [1, grpNull];
} forEach _groups;

//Delete all vehicles
_catID = T_VEH;
_cat = _lo getVariable ["g_veh", []];
_catSize = T_VEH_SIZE;
_subCatID = 0;
while {_subCatID < _catSize} do
{
	_subCat = _cat select _subCatID;
	{
		_unit = _x;
		[_lo, [_catID, _subcatID, _unit select 2]] call gar_fnc_t_despawnUnit;
	} forEach _subCat;
	_subCatID = _subCatID + 1;
};

//Delete all drones

//Stop the enemies thread
//[_lo] call gar_fnc_t_stopEnemiesThread;
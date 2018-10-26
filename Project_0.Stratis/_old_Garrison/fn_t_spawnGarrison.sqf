/*
Used inside the thread to spawn units.
*/

#include "garrison.hpp"

params ["_lo", ["_debug", true]];

//Get side
private _side = _lo getVariable ["g_side", nil];

if(isNil "_side") exitWith
{
	diag_log format ["fn_t_spawnGarrison.sqf: garrison: %1, error: wrong side: %2", _lo getVariable ["g_name", ""], _side];
};

//Initialize some variables
private _catID = 0;
private _subcatID = 0;
private _cat = [];
private _subcat = [];
private _catSize = 0;
private _unit = [];
private _pos = getPos player; //Todo: assign position to spawned units
private _objectHandle = objNull;
private _groups = _lo getVariable ["g_groups", []];

//Loop through all the units in garrison and spawn them

//Spawn vehicles
_catID = T_VEH;
_cat = _lo getVariable ["g_veh", nil];
if(isNil "_cat") exitWith
{
	diag_log format ["fn_t_spawnGarrison.sqf: garrison: %1, error: vehicle garrison not initialized.", _lo getVariable ["g_name", ""]];
};

_catSize = T_VEH_SIZE;
_subcatID = 0;
while {_subcatID < _catSize} do
{
	_subcat = _cat select _subcatID;
	{ //Loop through all the units in this category
		_unit = _x;
		[_lo, _pos, [_catID, _subcatID, _unit select 2]] call gar_fnc_t_spawnUnit;
	} forEach _subcat;
	_subcatID = _subcatID + 1;
};

//Spawn infantry
_catID = T_INF;
_cat = _lo getVariable ["g_inf", nil];
_subcatID = 0;
if(isNil "_cat") exitWith
{
	diag_log format ["fn_t_spawnGarrison.sqf: garrison: %1, error: infantry garrison not initialized.", _lo getVariable ["g_name", ""]];
};

_catSize = T_INF_SIZE;
while {_subcatID < _catSize} do
{
	_subcat = _cat select _subcatID;
	{ //Loop through all the units in this category
		_unit = _x;
		[_lo, _pos, [_catID, _subcatID, _unit select 2]] call gar_fnc_t_spawnUnit;
	} forEach _subcat;
	_subcatID = _subcatID + 1;
};

//Spawn drones
//todo ...

//Start a script to handle spotted enemies
/*
[_lo] call gar_fnc_t_startEnemiesThread;
*/

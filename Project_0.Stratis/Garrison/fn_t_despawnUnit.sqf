/*
Used inside the thread to despawn one unit
*/

#include "garrison.hpp"

params ["_lo", "_unitData"];

private _unit = [_lo, _unitData, 0] call gar_fnc_getUnit;

if(_unit isEqualTo []) exitWIth //Error: unit with this ID not found
{
	diag_log format ["fn_t_despawnUnit.sqf: garrison: %1, unit not found: %2", _lo getVariable ["g_name", ""], _unitData];
};

//Despawn unit
private _objectHandle = _unit select 1;
deleteVehicle _objectHandle;
//Set unit's parameters in garrison array
_unit set [1, objNull]; //Object handle
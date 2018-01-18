/**
 * Project_0 - fn_cargoInfantryCapacity
 * 
 * Author: Sparker
 * 
 * Description:
 * Returns how many units can be loaded by all the vehicles from _vehArray
 * 
 * Parameter(s):
 * _vehArray - a single vehicle/vehicle classname OR an array of vehicles or vehicle classnames
 
 * 
 * Return Value:
 * Number - 
 * 
 */

private _vehArray = _this;

if(_vehArray isEqualType objNull) then
{
	_vehArray = [_vehArray];
};

//diag_log format ["===== vehArray: %1", _vehArray];

//Now we consider only loading of infantry
private _nCargoSeats = 0;
for "_i" from 0 to ((count _vehArray) - 1) do
{
	private _veh = _vehArray select _i;
	private _fullCrew = _veh call misc_fnc_getFullCrew;
	private _nCargo = (count (_fullCrew select 3)) + (_fullCrew select 4); //FFV turrets + cargo seats
	_nCargoSeats = _nCargoSeats + _nCargo;
};

_nCargoSeats
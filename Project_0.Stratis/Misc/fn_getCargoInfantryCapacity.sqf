/*
Function: misc_fnc_getCargoInfantryCapacity
Returns how many units can be loaded as cargo by all the vehicles from _veh

Parameters: _veh

_vehArray - a single vehicle/vehicle classname OR an array of vehicles or vehicle classnames

Returns: Number
*/

private _vehArray = _this;

if(!(_vehArray isEqualType [])) then
{
	_vehArray = [_vehArray];
};

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
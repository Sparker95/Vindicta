/*
Checks if all the transport vehicles from _garTransport garrison can load all the units from _garsCargo garrisons.

Return value:
	true or false
*/

#include "garrison.hpp"

params ["_garTransport", "_garsCargo"];

private _allUnits = _garTransport call gar_fnc_getAllUnits;
private _allVehicles = _allUnits select {_x select 0 == T_VEH || _x select 0 == T_DRONE};

//Now we consider only loading of infantry
private _allVehicleClassnames = [];
for "_i" from 0 to ((count _allVehicles) - 1) do
{
	private _unitData = _allVehicles select _i;
	private _unit = [_garTransport, _unitData] call gar_fnc_getUnit;
	_allVehicleClassnames pushBack (_unit select G_UNIT_CLASSNAME);
};
private _nCargoSeats = _allVehicleClassnames call misc_fnc_getCargoInfantryCapacity;

//Count the amount of infantry units to be transported
private _nCargoInfantry = 0;
for "_i" from 0 to ((count _garsCargo) - 1) do
{
	private _garCargo = _garsCargo select _i;
	_nCargoInfantry = _nCargoInfantry + (count (_garCargo call gar_fnc_getAllUnits));
};

if (_nCargoSeats >= _nCargoInfantry) then
{
	true
}
else
{
	false
};

#include "defineCommon.inc"

/*
	Author: Jeroen Notenbomer

	Description:
	rearm vehicle with objects that have ammoCargo.
	used by addActionRearm

	Parameter(s):
		object: object to rearm
		object: object to rearm from
	
	Returns:

	
*/

params["_vehicleTo","_vehicleFrom"];

//get cost
pr _totalCost = 0;
pr _costs = _vehicleTo call JN_fnc_ammo_getLoadoutCost;
{
	_totalCost = _totalCost + _x;
}forEach (_costs select 2);

pr _cargo = _vehicleFrom call JN_fnc_ammo_getCargo;
if(_totalCost > _cargo)exitWith{hint "to less points"};

[_vehicleFrom,(_cargo - _totalCost)] call JN_fnc_ammo_setCargo;

_vehicleTo setVehicleAmmo 1;

hint "Vehicle rearmed";
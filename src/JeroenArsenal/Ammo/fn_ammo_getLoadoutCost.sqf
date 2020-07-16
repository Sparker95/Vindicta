#include "defineCommon.inc"

/*
	Author: Jeroen Notenbomer

	Description:
	Get loadout cost per turrets

	Parameter(s):
	Object

	Returns: 
	
	Usage: No use for end user, use  garage_init instead
	
*/

params ["_vehicle"];

pr _missingAmmoTurrets = _vehicle call JN_fnc_ammo_getLoadoutMissing;

pr _turretCost = [];
{
	pr _missingAmmoTurret = _x;
	pr _cost = 0;
	{
		_x params ["_magClass","_amount"];
		_cost = _cost + (([_magClass] call JN_fnc_ammo_getCost) * _amount);
		
	}forEach _missingAmmoTurret;
	_turretCost pushBack _cost;
}forEach (_missingAmmoTurrets select 1);

pr _pylonCost = [];
{
	_x params ["_magClass","_amount"];
	_pylonCost pushback (([_magClass] call JN_fnc_ammo_getCost) * _amount);
}foreach (_vehicle call JN_fnc_ammo_getPylonLoadoutMissing);

[_missingAmmoTurrets select 0, _turretCost, _pylonCost];
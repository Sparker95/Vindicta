#include "defineCommon.inc"

_vehicle = cursorObject;

_missingAmmoTurrets = _vehicle call JN_fnc_ammo_getLoadoutMissing;

_costTotal = [];
{
	pr _missingAmmoTurret = _x;
	pr _cost = 0;
	{
		_x params ["_magClass","_amount"];
		pr _ammoClass = getText(configfile >> "CfgMagazines" >> _magClass >> "ammo");
		_cost = _cost + (getNumber (configfile >> "CfgAmmo" >> _ammoClass >> "cost") * _amount);
		
	}forEach _missingAmmoTurret;
	_costTotal pushBack _cost;
}forEach (_missingAmmoTurrets select 1);

[_missingAmmoTurrets select 0, _costTotal];
#include "defineCommon.inc"

/*
	Author: Jeroen Notenbomer

	Description:
	Get cost of ammo in a magazine

	Parameter(s):
	String: magazine class name

	Returns:
	[_magClass] call JN_fnc_ammo_getCost;
	
*/

params ["_magClass"];


pr _ammoClass = getText(configfile >> "CfgMagazines" >> _magClass >> "ammo");

getNumber (configfile >> "CfgAmmo" >> _ammoClass >> "cost");
		
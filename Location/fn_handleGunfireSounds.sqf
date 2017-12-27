/*
This function handles gunfire sounds produced by other units.

_weaponType:
	0 - light weapons
	1 - medium weapons
	2 - heavy weapons
	3 - artillery
*/

params ["_loc", "_weaponType"];

private _weapon = ["light", "medium", "heavy", "artillery"];
diag_log format ["fn_handleGunfireSounds: location: %1, weapon type: %2", _loc getVariable ["l_name", "unknown name"],
 _weapon select _weaponType];
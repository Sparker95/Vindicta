/*
This function handles gunfire sounds produced by other units.
The main intention for now is to change alert states.

Parameters:
	_loc - the location object
	_weponTypes - array of weapon types

_weaponType - weapon type (specified in Sense.hpp)
	0 - light weapons
	1 - medium weapons
	2 - heavy weapons
	3 - artillery
*/

#include "..\Sense\Sense.hpp"

params ["_loc", "_soundType"];

//private _weapon = ["light weapons", "medium weapons", "heavy weapons", "artillery! holy $@#& take cover!"];

//{
//	diag_log format ["fn_handleGunfireSounds: location: %1 hears sounds: %2",
//		_loc getVariable ["l_name", "unknown name"], _weapon select _weaponType];
//} forEach _weaponTypes;

private _newAS = LOC_AS_aware;
if(_soundType > S_SOUND_FIRE_MEDIUM) then
{
	_newAS = LOC_AS_combat;
};
_loc setVariable ["l_alertStateSound", _newAS, false];
_loc setVariable ["l_alertStateTimer", 600, 0]; //How much time the location will be in this alert state
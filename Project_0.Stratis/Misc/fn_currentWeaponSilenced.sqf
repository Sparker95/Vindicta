/*
Function: misc_fnc_currentWeaponSilenced
Checks if given unit is currently using a silenced weapon.

Parameters: _unit

_unit - objectHandle of the unit

Returns:

silenced - Bool [true/false] - is the current weapon of the unit silenced?
*/

params ["_unit"];

//Check if the current weapon has an attachment in silencer slot
_s = _unit weaponAccessories (currentWeapon _unit) select 0;
if(_s != "") exitWith
{
	//Check if the silencer attachment is indeed a silencer by checking the audibleFire
	_a = getNumber (configfile >> "CfgWeapons" >> _s >> "ItemInfo" >> "AmmoCoef" >> "audibleFire");
	if(_a < 1) then
	{true}
	else
	{false};
};

//If there is no silencer, check weapon's ammo audibleFire coefficient
_mag = currentMagazine (vehicle _unit);
_ammo = getText (configFile >> "cfgMagazines" >> _mag >> "ammo");
_ammoAudible = getNumber (configFile >> "cfgAmmo" >> _ammo >> "audibleFire");
//Compare with threshold value
if(_ammoAudible < 5.5) then //See table below for more values
{true}
else
{false};


/*
auidibleFire data for different ammo and silencer attachments:

configfile >> "CfgAmmo" >> _ammo >> "audibleFire"
configfile >> "CfgWeapons" >> _attachment >> "ItemInfo" >> "AmmoCoef" >> "audibleFire"

standard 5.56mm		35
standard .45		45 (handgun)
standard .50		120 LRRs
standard 9.3mm		80 (The marksmen DLC rifle)
standard 12.7mm		5 (KIR with builtin silencer)
RHS 5.45mm			7
RHS 5.56mm 			7
RHS 7.62mm 			7
RHS 9mm				5.65 (handgun)
RHS 9mm				2.5 (val/vintorez builtin silencer)

attachments:
RHS non-silencers:	1.0
RHS silencers:		0.4
standard silencers:	0.04
*/

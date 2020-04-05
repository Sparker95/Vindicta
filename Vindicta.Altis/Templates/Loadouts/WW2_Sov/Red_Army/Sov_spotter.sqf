comment "Exported from Arsenal by MatrikSky";

removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

/*Helmet*/

/*Gogles*/
this addGoggles "G_LIB_Binoculars";
/*Uniform*/
this forceAddUniform "U_LIB_SOV_Sniper";
/*Vest*/
this addVest "V_LIB_SOV_RAZV_SVTBelt";
/*Backpack*/
_RandomBackpack = selectRandom ["B_LIB_SOV_RA_GasBag", "", "", ""];
this addBackpack _RandomBackpack;

/*Weapon*/
this addWeapon "LIB_SVT_40";
this addWeapon "LIB_TT33";
/*WeaponItem*/
this addPrimaryWeaponItem "lib_10rnd_762x54";
this addHandgunItem "LIB_8Rnd_762x25";
this addPrimaryWeaponItem "optic_PU";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "lib_10rnd_762x54";};
for "_i" from 1 to 3 do {this addItemToVest "LIB_5Rnd_762x54";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_8Rnd_762x25";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_Rg42";};
this addItemToVest "LIB_Rpg6";
this addItemToVest "LIB_RDG";

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "LIB_Binocular_SU";

[this,"Default","male01su"] call BIS_fnc_setIdentity;

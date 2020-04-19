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
this addHeadgear "H_LIB_SOV_RA_Helmet";
/*Uniform*/
this forceAddUniform "U_LIB_SOV_Efreitor_summer";
/*Vest*/
this addVest "V_LIB_SOV_RA_SVTBelt";
/*Backpack*/
_RandomBackpack = selectRandom ["B_LIB_SOV_RA_GasBag", "B_LIB_SOV_RA_GasBag", "B_LIB_SOV_RA_GasBag", "B_LIB_SOV_RA_Radio_ACRE2"];
this addBackpack _RandomBackpack;

/*Weapon*/
this addWeapon "LIB_SVT_40";
/*WeaponItem*/
this addPrimaryWeaponItem "lib_10rnd_762x54";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "lib_10rnd_762x54";};
for "_i" from 1 to 3 do {this addItemToVest "LIB_5Rnd_762x54";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_Rg42";};
this addItemToVest "LIB_Rpg6";
this addItemToVest "LIB_RDG";

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "LIB_Binocular_SU";

[this,"Default","male01su"] call BIS_fnc_setIdentity;

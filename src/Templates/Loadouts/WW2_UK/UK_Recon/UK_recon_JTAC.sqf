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
_RandomHeadgear = selectRandom ["H_LIB_UK_Beret_Commando", "H_LIB_UK_Helmet_Mk2_Camo", "H_LIB_UK_Helmet_Mk2_FAK_Camo", "H_LIB_UK_Helmet_Mk3_Camo"];
this addHeadgear _RandomHeadgear;
/*Gogles*/
_RandomGoggles = selectRandom ["G_LIB_Binoculars", ""];
this addGoggles _RandomGoggles;
/*Uniform*/
this forceAddUniform "fow_u_uk_bd40_commando_01_private";
/*Vest*/
_RandomVest = selectRandom ["V_LIB_UK_P37_Rifleman_Blanco", "V_LIB_UK_P37_Gasmask_Blanco"];
this addVest _RandomVest;
/*Backpack*/
_RandomBackpack = selectRandom ["B_LIB_US_Radio_ACRE2"];
this addBackpack _RandomBackpack;

/*Weapon*/
this addWeapon "LIB_Sten_Mk5";
/*WeaponItem*/
this addPrimaryWeaponItem "lib_32rnd_9x19_sten";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "lib_32rnd_9x19_sten";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_MillsBomb";};
this addItemToVest "LIB_US_M18";
this addItemToVest "LIB_No77";
this addItemToVest "fow_e_mk2";

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "LIB_Binocular_UK";

[this,"Default","male02engb"] call BIS_fnc_setIdentity;

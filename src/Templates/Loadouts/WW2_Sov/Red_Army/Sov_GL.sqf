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
_RandomHeadgear = selectRandom ["H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_Helmet", "H_LIB_SOV_RA_Helmet", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_Helmet", "H_LIB_SOV_RA_Helmet", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_Helmet", "H_LIB_SOV_RA_Helmet", "H_LIB_SOV_Ushanka", "H_LIB_SOV_Ushanka2"];
this addHeadgear _RandomHeadgear;
/*Uniform*/
this forceAddUniform "U_LIB_SOV_Strelok_summer";
/*Vest*/
this addVest "V_LIB_SOV_RA_MosinBelt";
/*Backpack*/
_RandomBackpack = selectRandom ["B_LIB_SOV_RA_Rucksack", "B_LIB_SOV_RA_Rucksack_Green", "B_LIB_SOV_RA_Rucksack_Gas_Kit", "B_LIB_SOV_RA_Rucksack_Gas_Kit_Green", "B_LIB_SOV_RA_Rucksack2_Gas_Kit", "B_LIB_SOV_RA_Rucksack2_Gas_Kit_Green", "B_LIB_SOV_RA_Rucksack2", "B_LIB_SOV_RA_Rucksack2_Green", "B_LIB_SOV_RA_Rucksack2_Shinel", "B_LIB_SOV_RA_Rucksack2_Shinel_Green", "B_LIB_SOV_RA_GasBag", "B_LIB_SOV_RA_Rucksack2_Gas_Kit_Shinel", "B_LIB_SOV_RA_Rucksack2_Gas_Kit_Shinel_Green", "B_LIB_SOV_RA_Shinel"];
this addBackpack _RandomBackpack;

/*Weapon*/
this addWeapon "LIB_M9130";
/*WeaponItem*/
this addPrimaryWeaponItem "lib_5rnd_762x54";
this addPrimaryWeaponItem "LIB_ACC_GL_DYAKONOV_Empty";
this addSecondaryWeaponItem "LIB_1Rnd_G_PZGR_30";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 5 do {this addItemToVest "lib_5rnd_762x54";};
for "_i" from 1 to 3 do {this addItemToVest "LIB_1Rnd_G_DYAKONOV";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_Rg42";};
this addItemToVest "LIB_Rpg6";
this addItemToVest "LIB_RDG";

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";

[this,"Default","male02su"] call BIS_fnc_setIdentity;

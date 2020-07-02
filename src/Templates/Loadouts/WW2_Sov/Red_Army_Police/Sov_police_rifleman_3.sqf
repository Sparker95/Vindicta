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
_RandomHeadgear = selectRandom ["H_LIB_SOV_RA_PrivateCap_NKVDSE", "H_LIB_SOV_RA_PrivateCap_NKVD"];
this addHeadgear _RandomHeadgear;
/*Uniform*/
this forceAddUniform "U_LIB_SOV_NKVD_soldier_1v2pRdvM30";
/*Vest*/
this addVest "V_LIB_SOV_RA_MGBelt";
/*Backpack*/
_RandomBackpack = selectRandom ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "B_LIB_SOV_RA_Rucksack", "B_LIB_SOV_RA_Rucksack_Green", "B_LIB_SOV_RA_Rucksack_Gas_Kit", "B_LIB_SOV_RA_Rucksack_Gas_Kit_Green", "B_LIB_SOV_RA_Rucksack2_Gas_Kit", "B_LIB_SOV_RA_Rucksack2_Gas_Kit_Green", "B_LIB_SOV_RA_Rucksack2", "B_LIB_SOV_RA_Rucksack2_Green", "B_LIB_SOV_RA_Rucksack2_Shinel", "B_LIB_SOV_RA_Rucksack2_Shinel_Green", "B_LIB_SOV_RA_GasBag", "B_LIB_SOV_RA_Rucksack2_Gas_Kit_Shinel", "B_LIB_SOV_RA_Rucksack2_Gas_Kit_Shinel_Green", "B_LIB_SOV_RA_Shinel"];
this addBackpack _RandomBackpack;

/*Weapon*/
this addWeapon "LIB_TT33";
/*WeaponItem*/
this addPrimaryWeaponItem "LIB_8Rnd_762x25";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToVest "LIB_8Rnd_762x25";};
this addItemToVest "LIB_Rg42";

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";

[this,"Default","male02su"] call BIS_fnc_setIdentity;

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
_RandomHeadgear = selectRandom ["H_LIB_SOV_RA_Helmet", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_Helmet", "H_LIB_SOV_RA_Helmet", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_Helmet", "H_LIB_SOV_RA_Helmet", "H_LIB_SOV_Ushanka", "H_LIB_SOV_Ushanka2"];
this addHeadgear _RandomHeadgear;
/*Uniform*/
this forceAddUniform "U_LIB_SOV_Razvedchik_am";
/*Vest*/
this addVest "V_LIB_SOV_RAZV_PPShBelt_Mag";
/*Backpack*/
_RandomBackpack = selectRandom ["B_LIB_SOV_RA_Rucksack", "B_LIB_SOV_RA_Rucksack_Green", "B_LIB_SOV_RA_Rucksack_Gas_Kit", "B_LIB_SOV_RA_Rucksack_Gas_Kit_Green", "B_LIB_SOV_RA_Rucksack2_Gas_Kit", "B_LIB_SOV_RA_Rucksack2_Gas_Kit_Green", "B_LIB_SOV_RA_Rucksack2", "B_LIB_SOV_RA_Rucksack2_Green", "B_LIB_SOV_RA_Rucksack2_Shinel", "B_LIB_SOV_RA_Rucksack2_Shinel_Green", "B_LIB_SOV_RA_GasBag", "B_LIB_SOV_RA_Rucksack2_Gas_Kit_Shinel", "B_LIB_SOV_RA_Rucksack2_Gas_Kit_Shinel_Green", "B_LIB_SOV_RA_Shinel"];
this addBackpack _RandomBackpack;

/*Weapon*/
this addWeapon "IFA3_PPS43";
/*WeaponItem*/
this addPrimaryWeaponItem "ifa3_35rnd_762x25_pps";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToVest "ifa3_35rnd_762x25_pps";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_Rg42";};
this addItemToVest "LIB_Rpg6";
this addItemToVest "LIB_RDG";
this addItemToBackpack "LIB_TMI_42_MINE_mag";
this addItemToBackpack "LIB_US_TNT_4pound_mag";
this addItemToBackpack "LIB_Ladung_Big_MINE_mag";
this addItemToBackpack "LIB_Ladung_Small_MINE_mag";
this addItemToBackpack "LIB_TM44_MINE_mag";

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";

[this,"Default","male03su"] call BIS_fnc_setIdentity;

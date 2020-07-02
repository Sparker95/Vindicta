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
this addHeadgear "H_LIB_SOV_TankHelmet";
/*Uniform*/
_RandomUniform = selectRandom ["U_LIB_SOV_Tank_ryadovoi", "U_LIB_SOV_Tank_ryadovoi", "U_LIB_SOV_Tank_ryadovoi", "U_LIB_SOV_Tank_ryadovoi", "U_LIB_SOV_Tank_ryadovoi", "U_LIB_SOV_Tank_leutenant", "U_LIB_SOV_Tank_sergeant"];
this forceAddUniform _RandomUniform;
/*Vest*/
this addVest "V_LIB_SOV_RA_PPShBelt_Mag";
/*Backpack*/
_RandomBackpack = selectRandom ["B_LIB_SOV_RA_Rucksack", "B_LIB_SOV_RA_Rucksack_Green", "B_LIB_SOV_RA_Rucksack_Gas_Kit", "B_LIB_SOV_RA_Rucksack_Gas_Kit_Green", "B_LIB_SOV_RA_Rucksack2_Gas_Kit", "B_LIB_SOV_RA_Rucksack2_Gas_Kit_Green", "B_LIB_SOV_RA_Rucksack2", "B_LIB_SOV_RA_Rucksack2_Green", "B_LIB_SOV_RA_Rucksack2_Shinel", "B_LIB_SOV_RA_Rucksack2_Shinel_Green", "B_LIB_SOV_RA_GasBag", "B_LIB_SOV_RA_Rucksack2_Gas_Kit_Shinel", "B_LIB_SOV_RA_Rucksack2_Gas_Kit_Shinel_Green", "B_LIB_SOV_RA_Shinel"];
this addBackpack _RandomBackpack;

/*Weapon*/
this addWeapon "LIB_TT33";
/*WeaponItem*/
this addHandgunItem "LIB_8Rnd_762x25";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToVest "LIB_8Rnd_762x25";};

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";

[this,"Default","male01su"] call BIS_fnc_setIdentity;

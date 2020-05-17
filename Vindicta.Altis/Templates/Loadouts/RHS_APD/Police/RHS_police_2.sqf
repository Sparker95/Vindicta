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
_RandomHeadgear = selectRandom ["State_Hat", "State_Hat", "H_Cap_police"];
this addHeadgear _RandomHeadgear;
/*Uniform*/
_RandomUniform = selectRandom ["APD_3", "APD_4", "APD_5", "APD_6"];
this forceaddUniform _RandomUniform;
/*Vest*/
_RandomVest = selectRandom ["S_VHO_PB_3", "S_VHO_OV_BLK_1", "S_VHO_OV_BLK_2", "S_VHO_OV_BLK_3", "S_VHO_OV_BLK_4", "S_VHO_OV_BLK_1", "S_VHO_OV_BLK_2", "S_VHO_OV_BLK_3", "S_VHO_OV_BLK_4"];
this addVest _RandomVest;
/*Backpack*/

/*Weapon*/
this addWeapon "rhs_weap_M590_5RD";
this addWeapon "rhsusf_weap_glock17g4";
/*WeaponItem*/
_RandomPrimaryWeaponItem = selectRandom ["rhsusf_acc_g33_xps3", "rhsusf_acc_eotech_xps3", "", "", "", ""];
this addPrimaryWeaponItem _RandomPrimaryWeaponItem;
this addPrimaryWeaponItem "rhsusf_acc_wmx_bk";
this addPrimaryWeaponItem "rhsusf_5Rnd_Slug";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "rhsusf_mag_17Rnd_9x19_FMJ";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "rhsusf_mag_17Rnd_9x19_FMJ";};
this addItemToUniform "ACE_M84";
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_5Rnd_00Buck";};
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_5Rnd_Slug";};
for "_i" from 1 to 2 do {this addItemToVest "ACE_Chemlight_HiBlue";};
for "_i" from 1 to 4 do {this addItemToVest "Chemlight_blue";};

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemGPS";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

[this,"Default","male03gre"] call BIS_fnc_setIdentity;

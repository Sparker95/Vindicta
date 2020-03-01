removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["State_Hat","SAPD_Barett","SAPD_Barett_Red", "rhsusf_opscore_bk", "rhsusf_opscore_bk_pelt"];
this addHeadgear _RandomHeadgear;
_RandomVest = selectRandom ["S_VHO_OV_BLK_1", "S_VHO_OV_BLK_2", "S_VHO_OV_BLK_3", "S_VHO_OV_BLK_4"];
this addVest _RandomVest;
_RandomUniform = selectRandom ["PD_1", "PD_2", "PD_3", "PD_4", "PD_5", "PD_6", "PD_7", "PD_8", "PD_9", "PD_10"];
this forceAddUniform _RandomUniform;

_RandomWeapon = selectRandom ["rhs_weap_mk17_CQC"];
this addWeapon _RandomWeapon;
_RandomPrimaryWeaponItem = selectRandom ["rhsusf_acc_tdstubby_blk", "rhsusf_acc_grip3", "rhsusf_acc_rvg_blk", ""];
this addPrimaryWeaponItem _RandomPrimaryWeaponItem;
_RandomPrimaryWeaponItem = selectRandom ["rhsusf_acc_g33_xps3", "rhsusf_acc_eotech_xps3", ""];
this addPrimaryWeaponItem _RandomPrimaryWeaponItem;
this addPrimaryWeaponItem "acc_flashlight";
this addPrimaryWeaponItem "rhs_mag_20Rnd_SCAR_762x51_m80_ball";
this addWeapon "hgun_P07_F";
this addHandgunItem "16Rnd_9x21_Mag";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "16Rnd_9x21_Mag";};
this addItemToUniform "ACE_M84";
for "_i" from 1 to 4 do {this addItemToVest "rhs_mag_20Rnd_SCAR_762x51_m80_ball";};
for "_i" from 1 to 2 do {this addItemToVest "ACE_Chemlight_HiBlue";};
for "_i" from 1 to 4 do {this addItemToVest "Chemlight_blue";};

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemGPS";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

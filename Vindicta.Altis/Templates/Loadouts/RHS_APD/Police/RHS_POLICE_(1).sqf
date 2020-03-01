removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["State_Hat","APD_Berett", "rhsusf_ach_bare", "rhsusf_ach_bare_headset"];
this addHeadgear _RandomHeadgear;
_RandomVest = selectRandom ["S_VHO_OV_BLK_1", "S_VHO_OV_BLK_2", "S_VHO_OV_BLK_3", "S_VHO_OV_BLK_4"];
this addVest _RandomVest;
_RandomUniform = selectRandom ["APD_1", "APD_2", "APD_3", "APD_4", "APD_5", "APD_6", "APD_7", "APD_8", "APD_9", "APD_10"];
this forceAddUniform _RandomUniform;

_RandomWeapon = selectRandom ["rhs_weap_m4_carryhandle_mstock", "rhs_weap_m4_carryhandle", "rhs_weap_m4a1_carryhandle", "rhs_weap_m4a1_carryhandle_mstock", "rhs_weap_m16a4_carryhandle"];
this addWeapon _RandomWeapon;
_RandomPrimaryWeaponItem = selectRandom ["rhsusf_acc_tdstubby_blk", "rhsusf_acc_grip3", "rhsusf_acc_rvg_blk", ""];
this addPrimaryWeaponItem _RandomPrimaryWeaponItem;
_RandomPrimaryWeaponItem = selectRandom ["rhsusf_acc_g33_xps3", "rhsusf_acc_eotech_xps3", ""];
this addPrimaryWeaponItem _RandomPrimaryWeaponItem;
this addPrimaryWeaponItem "acc_flashlight";
this addPrimaryWeaponItem "rhs_mag_30Rnd_556x45_M855_Stanag";
this addWeapon "rhsusf_weap_glock17g4";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "rhsusf_mag_17Rnd_9x19_FMJ";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "rhsusf_mag_17Rnd_9x19_FMJ";};
this addItemToUniform "ACE_M84";
for "_i" from 1 to 3 do {this addItemToVest "rhs_mag_30Rnd_556x45_M855_Stanag";};
for "_i" from 1 to 2 do {this addItemToVest "ACE_Chemlight_HiBlue";};
for "_i" from 1 to 4 do {this addItemToVest "Chemlight_blue";};

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemGPS";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

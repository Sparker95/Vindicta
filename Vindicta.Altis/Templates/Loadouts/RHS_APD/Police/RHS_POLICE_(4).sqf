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

_RandomWeapon = selectRandom ["rhs_weap_m24sws"];
this addWeapon _RandomWeapon;
this addPrimaryWeaponItem "rhsusf_acc_M8541_low";
this addPrimaryWeaponItem "rhsusf_5Rnd_762x51_m118_special_Mag";
this addWeapon "hgun_P07_F";
this addHandgunItem "16Rnd_9x21_Mag";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "16Rnd_9x21_Mag";};
this addItemToUniform "ACE_M84";
for "_i" from 1 to 3 do {this addItemToVest "rhsusf_5Rnd_762x51_m118_special_Mag";};
for "_i" from 1 to 2 do {this addItemToVest "ACE_Chemlight_HiBlue";};
for "_i" from 1 to 4 do {this addItemToVest "Chemlight_blue";};

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemGPS";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

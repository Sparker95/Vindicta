removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["State_Hat","APD_Berett", "H_Cap_police"];
this addHeadgear _RandomHeadgear;
_RandomVest = selectRandom ["S_VHO_PB_3", "S_VHO_OV_BLK_1", "S_VHO_OV_BLK_2", "S_VHO_OV_BLK_3", "S_VHO_OV_BLK_4"];
this addVest _RandomVest;
_RandomUniform = selectRandom ["APD_1", "APD_2", "APD_3", "APD_4", "APD_5", "APD_6", "APD_7", "APD_8", "APD_9", "APD_10"];
this forceAddUniform _RandomUniform;

this addWeapon "hgun_Pistol_heavy_01_F";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "optic_MRD";
this addHandgunItem "11Rnd_45ACP_Mag";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToUniform "11Rnd_45ACP_Mag";};
for "_i" from 1 to 2 do {this addItemToVest "ACE_Chemlight_HiBlue";};
for "_i" from 1 to 4 do {this addItemToVest "Chemlight_blue";};

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemGPS";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

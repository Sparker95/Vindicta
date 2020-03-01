removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["State_Hat","SAPD_Barett","SAPD_Barett_Red", "H_Cap_police"];
this addHeadgear _RandomHeadgear;
_RandomVest = selectRandom ["S_VHO_PB_3", "S_VHO_OV_BLK_1", "S_VHO_OV_BLK_2", "S_VHO_OV_BLK_3", "S_VHO_OV_BLK_4"];
this addVest _RandomVest;
_RandomUniform = selectRandom ["PD_1", "PD_2", "PD_3", "PD_4", "PD_5", "PD_6", "PD_7", "PD_8", "PD_9", "PD_10"];
this forceAddUniform _RandomUniform;

this addWeapon "hgun_ACPC2_F";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "9Rnd_45ACP_Mag";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToUniform "9Rnd_45ACP_Mag";};
for "_i" from 1 to 2 do {this addItemToVest "ACE_Chemlight_HiBlue";};
for "_i" from 1 to 4 do {this addItemToVest "Chemlight_blue";};

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemGPS";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

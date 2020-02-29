removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["H_Beret_gen_F","H_MilCap_gen_F"];
this addHeadgear _RandomHeadgear;
_RandomVest = selectRandom ["V_TacVest_gen_F", "V_Rangemaster_belt", "V_Safety_yellow_F"];
this addVest _RandomVest;
_RandomUniform = selectRandom ["U_B_GEN_Commander_F", "U_B_GEN_Soldier_F"];
this forceAddUniform _RandomUniform;

this addWeapon "hgun_ACPC2_F";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "9Rnd_45ACP_Mag";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToUniform "9Rnd_45ACP_Mag";};
for "_i" from 1 to 2 do {this addItemToVest "ACE_Chemlight_HiBlue";};
for "_i" from 1 to 4 do {this addItemToVest "Chemlight_blue";};

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

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
this forceAddUniform "U_B_GEN_Commander_F", "U_B_GEN_Soldier_F";

this addWeapon "hgun_Rook40_F";
this addHandgunItem "16Rnd_9x21_Mag";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToUniform "16Rnd_9x21_Mag";};
for "_i" from 1 to 2 do {this addItemToVest "ACE_Chemlight_HiBlue";};
for "_i" from 1 to 4 do {this addItemToVest "Chemlight_blue";};

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";


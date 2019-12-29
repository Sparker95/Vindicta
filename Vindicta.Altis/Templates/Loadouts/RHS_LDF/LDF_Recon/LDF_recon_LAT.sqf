removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomUniform = ["U_O_R_Gorka_01_F", "U_O_R_Gorka_01_brown_F"] call BIS_fnc_selectRandom;
this addUniform _RandomUniform;
_RandomHeadgear = ["rhssaf_booniehat_digital", "rhssaf_booniehat_digital", "rhssaf_bandana_digital", "rhssaf_bandana_smb", "rhs_beanie_green"] call BIS_fnc_selectRandom;
this addHeadgear _RandomHeadgear;
_RandomGoggles = ["G_Bandanna_khk", "G_Bandanna_oli", "G_Balaclava_oli", "" ] call BIS_fnc_selectRandom;
this addGoggles _RandomGoggles;
this addVest "V_TacVest_oli";
this addBackpack "rhs_rpg_empty";

this addWeapon "rhs_weap_aks74un";
this addPrimaryWeaponItem "rhs_acc_pbs4";
this addPrimaryWeaponItem "rhs_30Rnd_545x39_7N10_AK";
this addWeapon "rhs_weap_rpg7";
this addSecondaryWeaponItem "rhs_acc_pgo7v3";
this addSecondaryWeaponItem "rhs_rpg7_TBG7V_mag";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "rhs_mag_zarya2";};
this addItemToUniform "rhssaf_mag_br_m84";
this addItemToUniform "rhssaf_mag_br_m75";
for "_i" from 1 to 4 do {this addItemToVest "rhs_30Rnd_545x39_7U1_AK";};
for "_i" from 1 to 4 do {this addItemToVest "rhs_30Rnd_545x39_7N10_AK";};
this addItemToBackpack "rhs_rpg7_TBG7V_mag";
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_rpg7_PG7V_mag";};

this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhs_1PN138";

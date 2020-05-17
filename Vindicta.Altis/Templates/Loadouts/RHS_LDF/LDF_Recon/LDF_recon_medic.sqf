removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this forceaddUniform "U_O_R_Gorka_01_F";
_RandomHeadgear = selectRandom ["rhssaf_booniehat_digital", "rhssaf_booniehat_digital", "rhssaf_bandana_digital", "rhssaf_bandana_smb", "rhs_beanie_green"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["G_Bandanna_khk", "G_Bandanna_oli", "G_Balaclava_oli", "" ];
this addGoggles _RandomGoggles;
this addVest "V_TacVest_oli";
this addBackpack "rhs_medic_bag";

this addWeapon "rhs_weap_ak104";
this addPrimaryWeaponItem "rhs_acc_dtk4screws";
this addPrimaryWeaponItem "rhs_acc_perst1ik";
this addPrimaryWeaponItem "rhs_30Rnd_762x39mm_polymer";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhs_acc_1pn93_1";
for "_i" from 1 to 2 do {this addItemToUniform "rhs_mag_zarya2";};
this addItemToUniform "rhssaf_mag_br_m84";
this addItemToUniform "rhssaf_mag_br_m75";
for "_i" from 1 to 4 do {this addItemToVest "FirstAidKit";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_30Rnd_762x39mm_polymer_U";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_30Rnd_762x39mm_polymer";};
this addItemToVest "rhs_mag_rdg2_white";
this addItemToBackpack "Medikit";
for "_i" from 1 to 2 do {this addItemToBackpack "FirstAidKit";};

this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhs_1PN138";

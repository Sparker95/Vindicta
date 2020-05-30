removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this forceaddUniform "U_O_R_Gorka_01_F";
_RandomHeadgear = selectRandom ["rhssaf_booniehat_digital", "rhssaf_bandana_digital", "rhs_beanie_green", "H_MilCap_grn"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["G_Bandanna_khk", "G_Bandanna_oli", "" ];
this addGoggles _RandomGoggles;
this addVest "rhssaf_vest_md12_m70_rifleman";
this addBackpack "B_RadioBag_01_eaf_F";

this addWeapon "rhs_weap_ak103_gp25";
this addPrimaryWeaponItem "rhs_acc_dtk4screws";
this addPrimaryWeaponItem "rhs_VOG25";
this addPrimaryWeaponItem "rhs_30Rnd_762x39mm_polymer";
this addWeapon "rhs_pdu4";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhs_acc_1pn93_1";
for "_i" from 1 to 2 do {this addItemToUniform "rhs_mag_zarya2";};
this addItemToUniform "rhssaf_mag_br_m84";
this addItemToUniform "rhssaf_mag_br_m75";
for "_i" from 1 to 2 do {this addItemToVest "rhs_30Rnd_762x39mm_polymer_U";};
for "_i" from 1 to 3 do {this addItemToVest "rhs_30Rnd_762x39mm_polymer";};
for "_i" from 1 to 6 do {this addItemToBackpack "rhs_VG40TB";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_VG40MD";};
for "_i" from 1 to 4 do {this addItemToBackpack "rhs_VOG25";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_VOG25P";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_GRD40_Green";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_GRD40_Red";};

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "ItemGPS";
this linkItem "rhs_1PN138";

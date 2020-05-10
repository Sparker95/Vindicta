removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["rhssaf_helmet_m97_veil_digital","rhssaf_helmet_m97_digital","rhssaf_helmet_m97_digital_black_ess","rhssaf_helmet_m97_digital_black_ess_bare","rhssaf_helmet_m97_olive_nocamo","rhssaf_helmet_m97_olive_nocamo_black_ess","rhssaf_helmet_m97_olive_nocamo_black_ess_bare"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["G_Bandanna_oli","G_Balaclava_oli","rhsusf_shemagh_od","rhsusf_shemagh2_od","","",""];
this addGoggles _RandomGoggles;
this forceaddUniform "rhssaf_uniform_m10_digital_summer";
this addVest "rhssaf_vest_md99_digital_rifleman";
this addBackpack "B_LegStrapBag_olive_F";

this addWeapon "rhs_weap_ak74n_2_gp25";
this addPrimaryWeaponItem "rhs_acc_dtk1983";
this addPrimaryWeaponItem "rhs_30Rnd_545x39_7N10_plum_AK";
this addPrimaryWeaponItem "rhs_VOG25";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_rgd5";};
for "_i" from 1 to 4 do {this addItemToVest "rhs_30Rnd_545x39_7N10_plum_AK";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_VG40MD";};
this addItemToBackpack "rhs_GRD40_Green";
this addItemToBackpack "rhs_GRD40_Red";
for "_i" from 1 to 6 do {this addItemToBackpack "rhs_VOG25";};
this addItemToBackpack "rhs_VG40OP_red";
for "_i" from 1 to 4 do {this addItemToBackpack "rhs_VG40OP_white";};
this addItemToBackpack "rhs_VG40OP_green";
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_VOG25P";};
this linkItem "ItemWatch";
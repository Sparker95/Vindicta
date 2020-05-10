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
this addVest "rhssaf_vest_md99_digital";
this addWeapon "Binocular";

this addWeapon "rhs_weap_svds";
this addPrimaryWeaponItem "rhs_acc_pso1m2";
this addPrimaryWeaponItem "rhs_10Rnd_762x54mmR_7N1";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhs_acc_1pn93_1";
for "_i" from 1 to 8 do {this addItemToVest "rhs_10Rnd_762x54mmR_7N1";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_rgd5";};
this linkItem "ItemWatch";
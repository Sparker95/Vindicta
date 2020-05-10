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
this forceaddUniform "rhsgref_uniform_para_ttsko_urban";
this addVest "rhssaf_vest_md99_digital";
this addBackpack "rhssaf_kitbag_digital";

this addWeapon "rhs_weap_m240G";
this addPrimaryWeaponItem "rhsusf_50Rnd_762x51";

this addItemToUniform "FirstAidKit";
this addItemToVest "rhs_mag_f1";
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_50Rnd_762x51";};
for "_i" from 1 to 5 do {this addItemToBackpack "rhsusf_50Rnd_762x51";};
this linkItem "ItemWatch";
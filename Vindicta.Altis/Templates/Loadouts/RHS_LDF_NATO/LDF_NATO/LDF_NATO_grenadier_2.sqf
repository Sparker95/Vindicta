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
this addVest "rhssaf_vest_md12_digital";

this addWeapon "rhs_weap_m79";
this addPrimaryWeaponItem "rhs_mag_M441_HE";
this addWeapon "rhsusf_weap_glock17g4";
this addHandgunItem "rhsusf_mag_17Rnd_9x19_FMJ";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "rhsusf_mag_17Rnd_9x19_FMJ";};
for "_i" from 1 to 10 do {this addItemToVest "rhs_mag_M441_HE";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_M433_HEDP";};
for "_i" from 1 to 5 do {this addItemToVest "rhs_mag_M397_HET";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_m713_Red";};

this linkItem "ItemWatch";
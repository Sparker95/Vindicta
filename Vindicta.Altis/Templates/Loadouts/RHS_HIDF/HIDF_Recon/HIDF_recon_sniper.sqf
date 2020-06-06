removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomVest = selectRandom ["rhsgref_chestrig", "V_Chestrig_oli", "V_TacVest_oli", "rhsgref_TacVest_ERDL"];
this addVest _RandomVest;
_RandomGoggles = selectRandom ["G_Bandanna_oli", "rhsusf_shemagh_grn", "rhsusf_shemagh2_grn", "rhsusf_shemagh_gogg_grn", "rhsusf_shemagh2_gogg_grn", "", ""];
this addGoggles _RandomGoggles;
this addHeadgear "rhsgref_helmet_pasgt_erdl_rhino";
this forceaddUniform "rhs_uniform_bdu_erdl";

this addWeapon "rhs_weap_m14_socom_rail";
this addPrimaryWeaponItem "optic_KHS_blk";
this addPrimaryWeaponItem "rhsusf_20Rnd_762x51_m993_Mag";
this addWeapon "rhsusf_weap_m9";
this addHandgunItem "rhsusf_mag_15Rnd_9x19_JHP";
this addWeapon "Binocular";

this addItemToUniform "FirstAidKit";
this addItemToUniform "B_IR_Grenade";
for "_i" from 1 to 2 do {this addItemToUniform "rhsusf_mag_15Rnd_9x19_JHP";};
this addItemToUniform "rhs_grenade_anm8_mag";
for "_i" from 1 to 4 do {this addItemToVest "rhsusf_20Rnd_762x51_m993_Mag";};
this addItemToVest "rhs_grenade_m15_mag";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhsusf_ANPVS_14";
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
this addBackpack "B_AssaultPack_rgr";

this addWeapon "rhs_weap_m3a1_specops";
this addPrimaryWeaponItem "rhsgref_acc_RX01_NoFilter_camo";
this addPrimaryWeaponItem "rhsgref_30rnd_1143x23_M1T_2mag_SMG";
this addWeapon "rhsusf_weap_m9";
this addHandgunItem "rhsusf_mag_15Rnd_9x19_JHP";

this addItemToUniform "FirstAidKit";
this addItemToUniform "B_IR_Grenade";
this addItemToUniform "rhs_grenade_m15_mag";
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_mkiiia1_mag";};
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_mag_15Rnd_9x19_JHP";};
for "_i" from 1 to 4 do {this addItemToVest "rhsgref_30rnd_1143x23_M1T_2mag_SMG";};
this addItemToBackpack "SatchelCharge_Remote_Mag";
for "_i" from 1 to 2 do {this addItemToBackpack "DemoCharge_Remote_Mag";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_mag_an_m14_th3";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhsusf_ANPVS_14";
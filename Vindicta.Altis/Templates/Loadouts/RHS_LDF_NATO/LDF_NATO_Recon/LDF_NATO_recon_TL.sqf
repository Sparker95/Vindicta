removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomUniform = ["rhs_uniform_g3_rgr", "rhsgref_uniform_para_ttsko_urban"] call BIS_fnc_selectRandom;
this forceaddUniform _RandomUniform;
_RandomHeadgear = ["rhsusf_opscore_rg_cover", "rhsusf_opscore_paint", "rhssaf_Helmet_m97_woodland"] call BIS_fnc_selectRandom;
this addHeadgear _RandomHeadgear;
_RandomGoggles = ["rhs_googles_clear", "rhs_googles_yellow", "rhs_googles_orange" ] call BIS_fnc_selectRandom;
this addGoggles _RandomGoggles;
this addVest "rhsusf_mbav_rifleman";

this addWeapon "rhs_weap_hk416d10_LMT_wd";
this addPrimaryWeaponItem "rhsusf_acc_g33_T1";
this addPrimaryWeaponItem "rhsusf_acc_anpeq15_bk_light";
this addPrimaryWeaponItem "rhs_mag_30Rnd_556x45_M855A1_PMAG";
this addWeapon "rhs_weap_rshg2";
this addWeapon "rhsusf_weap_glock17g4";
this addHandgunItem "rhsusf_acc_omega9k";
this addHandgunItem "rhsusf_mag_17Rnd_9x19_FMJ";
this addWeapon "rhs_pdu4";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhs_acc_1pn93_1";
this addItemToUniform "rhs_30Rnd_762x39mm_polymer_tracer";
for "_i" from 1 to 4 do {this addItemToVest "rhs_mag_30Rnd_556x45_M855A1_PMAG";};
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_mag_17Rnd_9x19_FMJ";};
for "_i" from 1 to 2 do {this addItemToVest "ACE_CTS9";};
this addItemToVest "rhs_mag_m67";
this addItemToVest "ACE_CTS9";
this addItemToVest "rhs_mag_m18_green";
this addItemToVest "rhs_mag_30Rnd_556x45_M855A1_PMAG_Tracer_Red";
this addItemToVest "I_E_IR_Grenade";
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhsusf_ANPVS_14";


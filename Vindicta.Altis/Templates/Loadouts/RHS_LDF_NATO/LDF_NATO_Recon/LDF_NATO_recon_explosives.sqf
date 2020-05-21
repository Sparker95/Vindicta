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
this addBackpack "rhsusf_falconii";

this addWeapon "rhs_weap_hk416d10";
this addPrimaryWeaponItem "rhsusf_acc_T1_high";
this addPrimaryWeaponItem "rhsusf_acc_anpeq15_bk_light";
this addPrimaryWeaponItem "rhs_mag_30Rnd_556x45_M855A1_PMAG";

this addItemToUniform "FirstAidKit";
this addItemToVest "FirstAidKit";
this addItemToVest "ACE_CTS9";
this addItemToVest "I_E_IR_Grenade";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_m67";};
this addItemToVest "rhs_mag_m18_green";
for "_i" from 1 to 5 do {this addItemToVest "rhs_mag_30Rnd_556x45_M855A1_PMAG";};
this addItemToBackpack "ACE_M26_Clacker";
this addItemToBackpack "ACE_Clacker";
for "_i" from 1 to 3 do {this addItemToBackpack "rhsusf_m112_mag";};
this addItemToBackpack "rhssaf_mine_mrud_d_mag";

this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhsusf_ANPVS_14";

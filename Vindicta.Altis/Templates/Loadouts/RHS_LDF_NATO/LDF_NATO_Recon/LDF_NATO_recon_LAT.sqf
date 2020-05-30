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
this addWeapon "rhs_weap_maaws";
this addSecondaryWeaponItem "rhs_optic_maaws";
this addSecondaryWeaponItem "rhs_mag_maaws_HEDP";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "rhsusf_mag_17Rnd_9x19_FMJ";};
for "_i" from 1 to 2 do {this addItemToUniform "ACE_CTS9";};
this addItemToVest "rhs_mag_m67";
this addItemToVest "rhs_mag_m18_green";
this addItemToVest "I_E_IR_Grenade";
for "_i" from 1 to 5 do {this addItemToVest "rhs_mag_30Rnd_556x45_M855A1_PMAG";};
this addItemToBackpack "rhs_rpg7_TBG7V_mag";
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_mag_maaws_HEDP";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhsusf_ANPVS_14";
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
this addVest "rhsusf_plateframe_marksman";

this addWeapon "rhs_weap_SCARH_LB";
this addPrimaryWeaponItem "rhsusf_acc_su230a_mrds";
this addPrimaryWeaponItem "rhsusf_acc_anpeq15A";
this addPrimaryWeaponItem "rhs_mag_20Rnd_SCAR_762x51_m118_special";
this addWeapon "rhsusf_weap_glock17g4";
this addHandgunItem "rhsusf_mag_17Rnd_9x19_FMJ";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "rhsusf_mag_17Rnd_9x19_FMJ";};
for "_i" from 1 to 2 do {this addItemToUniform "ACE_CTS9";};
this addItemToVest "rhs_mag_m67";
this addItemToVest "rhs_mag_m18_green";
for "_i" from 1 to 5 do {this addItemToVest "rhs_mag_20Rnd_SCAR_762x51_m118_special";};

this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhsusf_ANPVS_14";

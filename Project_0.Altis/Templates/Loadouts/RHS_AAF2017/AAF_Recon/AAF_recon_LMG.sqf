removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomVest = ["FGN_AAF_CIRAS_SAW","FGN_AAF_CIRAS_SAW_Belt","FGN_AAF_CIRAS_SAW_Belt_CamB","FGN_AAF_CIRAS_SAW_CamB"] call BIS_fnc_selectRandom;
this addVest _RandomVest;
_RandomHeadgear = ["FGN_AAF_Boonie_Type07","rhsusf_opscore_mar_ut","rhsusf_opscore_mar_ut_pelt"] call BIS_fnc_selectRandom;
this addHeadgear _RandomHeadgear;
_RandomGoggles = ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","rhsusf_oakley_goggles_blk","",""] call BIS_fnc_selectRandom;
this addGoggles _RandomGoggles;
this forceAddUniform "rhs_uniform_gorka_1_a";
this addBackpack "FGN_AAF_Bergen_Type07";

this addWeapon "rhs_weap_m249_light_L_vfg2";
this addPrimaryWeaponItem "rhs_acc_perst1ik_ris";
this addPrimaryWeaponItem "rhsusf_acc_elcan_3d";
this addPrimaryWeaponItem "rhsusf_acc_grip4_bipod";
this addWeapon "rhsusf_weap_glock17g4";
this addHandgunItem "acc_flashlight_pistol";

this addItemToUniform "FirstAidKit";
this addItemToVest "rhs_grenade_anm8_mag";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_mk3a2";};
for "_i" from 1 to 3 do {this addItemToVest "rhsusf_mag_17Rnd_9x19_JHP";};
this addItemToVest "I_IR_Grenade";
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_100Rnd_556x45_mixed_soft_pouch_coyote";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhsusf_100Rnd_556x45_mixed_soft_pouch_coyote";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhsusf_200Rnd_556x45_mixed_soft_pouch_coyote";};

this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhsusf_ANPVS_14";

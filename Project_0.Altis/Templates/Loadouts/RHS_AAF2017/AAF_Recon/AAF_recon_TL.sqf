removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomVest = ["FGN_AAF_CIRAS_TL","FGN_AAF_CIRAS_TL_CamB"] call BIS_fnc_selectRandom;
this addVest _RandomVest;
_RandomHeadgear = ["FGN_AAF_Boonie_Type07","rhsusf_opscore_mar_ut","rhsusf_opscore_mar_ut_pelt"] call BIS_fnc_selectRandom;
this addHeadgear _RandomHeadgear;
_RandomGoggles = ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","rhsusf_oakley_goggles_blk","",""] call BIS_fnc_selectRandom;
this addGoggles _RandomGoggles;
this forceAddUniform "rhs_uniform_gorka_1_a";
this addBackpack "FGN_AAF_Bergen_SL_Type07";

this addWeapon "rhs_weap_g36c";
this addPrimaryWeaponItem "rhs_acc_perst3";
this addPrimaryWeaponItem "rhsusf_acc_eotech_xps3";
this addPrimaryWeaponItem "rhssaf_30rnd_556x45_EPR_G36";
this addPrimaryWeaponItem "rhs_acc_grip_ffg2";
this addWeapon "rhs_weap_rpg75";
this addWeapon "rhsusf_weap_glock17g4";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "rhsusf_mag_17Rnd_9x19_JHP";
this addWeapon "rhssaf_zrak_rd7j";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_mag_17Rnd_9x19_JHP";};
for "_i" from 1 to 7 do {this addItemToVest "rhssaf_30rnd_556x45_EPR_G36";};
for "_i" from 1 to 2 do {this addItemToVest "rhssaf_30rnd_556x45_Tracers_G36";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_anm8_mag";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_mk3a2";};
for "_i" from 1 to 2 do {this addItemToVest "rhssaf_mag_brz_m88";};

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhsusf_ANPVS_14";

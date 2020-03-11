removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["FGN_AAF_Boonie_Type07","rhsusf_opscore_mar_ut","rhsusf_opscore_mar_ut_pelt"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","rhsusf_oakley_goggles_blk","",""];
this addGoggles _RandomGoggles;
this forceAddUniform "rhs_uniform_gorka_1_a";
this addVest "FGN_AAF_CIRAS_MM";

this addWeapon "rhs_weap_SCARH_FDE_LB";
this addPrimaryWeaponItem "rhsgref_sdn6_suppressor";
this addPrimaryWeaponItem "rhsusf_acc_M8541_mrds";
this addPrimaryWeaponItem "rhs_mag_20Rnd_SCAR_762x51_m80a1_epr";
this addPrimaryWeaponItem "rhsusf_acc_harris_bipod";
this addWeapon "rhsusf_weap_glock17g4";
this addHandgunItem "rhsusf_acc_omega9k";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "rhsusf_mag_17Rnd_9x19_JHP";
this addWeapon "rhssaf_zrak_rd7j";

this addItemToUniform "FirstAidKit";
this addItemToUniform "optic_NVS";
for "_i" from 1 to 2 do {this addItemToUniform "rhs_mag_mk3a2";};
this addItemToVest "I_IR_Grenade";
for "_i" from 1 to 6 do {this addItemToVest "rhs_mag_20Rnd_SCAR_762x51_m80a1_epr";};
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_mag_17Rnd_9x19_JHP";};
this linkItem "ItemWatch";
this linkItem "NVGoggles_OPFOR";
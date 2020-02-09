removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomVest = selectRandom ["FGN_AAF_CIRAS_Engineer","FGN_AAF_CIRAS_Engineer_CamB"];
this addVest _RandomVest;
_RandomHeadgear = selectRandom ["FGN_AAF_Boonie_Type07","rhsusf_opscore_mar_ut","rhsusf_opscore_mar_ut_pelt"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","rhsusf_oakley_goggles_blk","",""];
this addGoggles _RandomGoggles;
this forceAddUniform "rhs_uniform_gorka_1_a";
this addBackpack "FGN_AAF_Bergen_Engineer_Type07";

this addWeapon "rhs_weap_hk416d145";
this addPrimaryWeaponItem "rhsusf_acc_rotex5_grey";
this addPrimaryWeaponItem "rhsusf_acc_anpeq15_bk_light_h";
this addPrimaryWeaponItem "rhsusf_acc_g33_xps3";
this addPrimaryWeaponItem "rhs_mag_30Rnd_556x45_M855A1_Stanag";
this addWeapon "rhsusf_weap_glock17g4";
this addHandgunItem "rhsusf_acc_omega9k";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "rhsusf_mag_17Rnd_9x19_JHP";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "rhsusf_mag_17Rnd_9x19_JHP";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_mk3a2";};
this addItemToVest "I_IR_Grenade";
for "_i" from 1 to 6 do {this addItemToVest "rhs_mag_30Rnd_556x45_M855A1_Stanag";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_charge_tnt_x2_mag";};
this addItemToBackpack "SatchelCharge_Remote_Mag";
for "_i" from 1 to 4 do {this addItemToBackpack "DemoCharge_Remote_Mag";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "NVGoggles_OPFOR";


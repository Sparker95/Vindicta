removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomGoggles = selectRandom ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","",""];
this addGoggles _RandomGoggles;
_RandomHeadgear = selectRandom ["FGN_AAF_Boonie_Type07","rhsusf_bowman_cap"];
this addHeadgear _RandomHeadgear;
this forceaddUniform "FGN_AAF_M10_Type07_Summer";
this addVest "FGN_AAF_CIRAS_RF01";

this addWeapon "rhsusf_weap_MP7A2_grip3";
this addPrimaryWeaponItem "rhsusf_acc_rotex_mp7";
this addPrimaryWeaponItem "rhsusf_acc_anpeq15side_bk";
this addPrimaryWeaponItem "rhsusf_acc_T1_high";
this addPrimaryWeaponItem "rhsusf_mag_40Rnd_46x30_AP";
this addPrimaryWeaponItem "rhsusf_acc_rvg_blk";
this addWeapon "rhsusf_weap_glock17g4";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "rhsusf_mag_17Rnd_9x19_JHP";

this addItemToUniform "FirstAidKit";
this addItemToUniform "I_IR_Grenade";
for "_i" from 1 to 2 do {this addItemToUniform "rhsusf_mag_17Rnd_9x19_JHP";};
this addItemToVest "rhs_grenade_mki_mag";
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_mkii_mag";};
this addItemToVest "rhs_grenade_anm8_mag";
for "_i" from 1 to 6 do {this addItemToVest "rhsusf_mag_40Rnd_46x30_AP";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "NVGoggles_OPFOR";
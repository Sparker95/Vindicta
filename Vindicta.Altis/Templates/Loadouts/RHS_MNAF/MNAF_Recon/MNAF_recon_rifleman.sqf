removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["H_Booniehat_oli","rhsusf_opscore_fg","rhsusf_opscore_fg_pelt","rhsusf_opscore_fg_pelt_cam"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["G_Bandanna_oli", "rhsusf_shemagh_grn", "rhsusf_shemagh2_grn", "rhsusf_shemagh_gogg_grn", "rhsusf_shemagh2_gogg_grn", "", ""];
this addGoggles _RandomGoggles;
this forceAddUniform "mnaf_lizardo";
this addVest "V_CarrierRigKBT_01_light_Olive_F";
this addBackpack "B_LegStrapBag_olive_F";

this addWeapon "rhs_weap_SCARH_LB";
this addPrimaryWeaponItem "rhsusf_acc_aac_scarh_silencer";
this addPrimaryWeaponItem "rhsusf_acc_anpeq15side_bk";
this addPrimaryWeaponItem "rhsusf_acc_M8541_mrds";
this addPrimaryWeaponItem "rhs_mag_20Rnd_SCAR_762x51_m61_ap_bk";
this addPrimaryWeaponItem "rhsusf_acc_harris_bipod";
this addWeapon "rhs_weap_m72a7";
this addWeapon "rhsusf_weap_glock17g4";
this addHandgunItem "rhsusf_acc_omega9k";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "rhsusf_mag_17Rnd_9x19_JHP";

this addItemToUniform "FirstAidKit";
this addItemToUniform "B_IR_Grenade";
for "_i" from 1 to 6 do {this addItemToVest "rhs_mag_20Rnd_SCAR_762x51_m61_ap_bk";};
for "_i" from 1 to 3 do {this addItemToVest "rhsusf_mag_17Rnd_9x19_JHP";};
this addItemToBackpack "rhs_mag_an_m8hc";
this addItemToBackpack "rhs_mag_an_m14_th3";
for "_i" from 1 to 4 do {this addItemToBackpack "rhs_mag_mk84";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "NVGoggles_OPFOR";
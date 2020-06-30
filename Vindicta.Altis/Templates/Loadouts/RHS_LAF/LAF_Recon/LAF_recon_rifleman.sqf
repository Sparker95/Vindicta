removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this addHeadgear "rhsgref_helmet_pasgt_flecktarn";
_RandomGoggles = selectRandom ["G_Balaclava_blk", "G_Bandanna_blk"];
this addGoggles _RandomGoggles;
this forceAddUniform "rhsgref_uniform_gorka_1_f";
this addVest "V_TacVestIR_blk";
this addBackpack "B_LegStrapBag_black_F";

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
this addItemToBackpack "optic_NVS";
for "_i" from 1 to 4 do {this addItemToBackpack "rhs_mag_mk84";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhsusf_ANPVS_15";
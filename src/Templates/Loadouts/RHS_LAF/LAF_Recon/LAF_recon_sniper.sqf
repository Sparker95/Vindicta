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
_RandomVest = selectRandom ["V_TacVestIR_blk", "V_Chestrig_blk"];
this addVest _RandomVest;
this forceAddUniform "rhsgref_uniform_gorka_1_f";
this addBackpack "B_LegStrapBag_black_F";

this addWeapon "rhs_weap_SCARH_LB";
this addPrimaryWeaponItem "rhsusf_acc_aac_scarh_silencer";
this addPrimaryWeaponItem "acc_pointer_IR";
this addPrimaryWeaponItem "rhsusf_acc_M8541_mrds";
this addPrimaryWeaponItem "rhs_mag_20Rnd_SCAR_762x51_m61_ap_bk";
this addPrimaryWeaponItem "rhsusf_acc_harris_bipod";
this addWeapon "rhsusf_weap_glock17g4";
this addHandgunItem "rhsusf_acc_omega9k";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "rhsusf_mag_17Rnd_9x19_JHP";

this addItemToUniform "FirstAidKit";
this addItemToUniform "B_IR_Grenade";
for "_i" from 1 to 2 do {this addItemToUniform "rhsusf_mag_17Rnd_9x19_JHP";};
for "_i" from 1 to 6 do {this addItemToVest "rhs_mag_20Rnd_SCAR_762x51_m61_ap_bk";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_20Rnd_SCAR_762x51_m62_tracer_bk";};
this addItemToBackpack "rhs_mag_an_m8hc";
this addItemToBackpack "rhs_mag_an_m14_th3";
for "_i" from 1 to 4 do {this addItemToBackpack "rhs_mag_mk84";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhsusf_ANPVS_15";
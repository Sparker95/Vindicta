removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this forceaddUniform "U_O_R_Gorka_01_F";
_RandomHeadgear = selectRandom ["rhssaf_booniehat_digital", "rhs_beanie_green", "H_MilCap_grn"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["G_Bandanna_khk", "G_Bandanna_oli", "G_Balaclava_oli", "" ];
this addGoggles _RandomGoggles;
this addVest "rhssaf_vest_md98_digital";
this addBackpack "B_LegStrapBag_olive_F";

this addWeapon "rhs_weap_svdp_wd";
this addPrimaryWeaponItem "rhs_acc_tgpv2";
this addPrimaryWeaponItem "rhs_acc_pso1m2";
this addPrimaryWeaponItem "rhs_10Rnd_762x54mmR_7N14";
this addWeapon "rhs_weap_pb_6p9";
this addHandgunItem "rhs_acc_6p9_suppressor";
this addHandgunItem "rhs_mag_9x18_8_57N181S";
this addWeapon "Binocular";

this addItemToUniform "FirstAidKit";
this addItemToUniform "I_E_IR_Grenade";
for "_i" from 1 to 2 do {this addItemToUniform "rhs_mag_9x18_8_57N181S";};
for "_i" from 1 to 10 do {this addItemToVest "rhs_10Rnd_762x54mmR_7N14";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_zarya2";};
this addItemToBackpack "rhs_acc_1pn34";
this addItemToBackpack "rhs_mag_rgn";
this addItemToBackpack "rhs_mag_rgo";
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_mag_zarya2";};
this addItemToBackpack "rhs_mag_rdg2_white";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "NVGoggles_OPFOR";
removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this forceaddUniform "U_O_R_Gorka_01_F";
_RandomHeadgear = selectRandom ["rhssaf_booniehat_digital", "rhssaf_booniehat_digital", "rhssaf_bandana_digital", "rhssaf_bandana_smb", "rhs_beanie_green"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["G_Bandanna_khk", "G_Bandanna_oli", "G_Balaclava_oli", "" ];
this addGoggles _RandomGoggles;
this addVest "rhssaf_vest_md98_digital";

this addWeapon "rhs_weap_svdp_wd";
this addPrimaryWeaponItem "rhs_acc_tgpv2";
this addPrimaryWeaponItem "rhs_acc_pso1m2";
this addPrimaryWeaponItem "rhs_10Rnd_762x54mmR_7N1";
this addWeapon "rhs_weap_pb_6p9";
this addHandgunItem "rhs_acc_6p9_suppressor";
this addHandgunItem "rhs_mag_9x18_8_57N181S";
this addWeapon "Binocular";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhs_acc_1pn93_1";
for "_i" from 1 to 2 do {this addItemToUniform "rhs_mag_9x18_8_57N181S";};
for "_i" from 1 to 2 do {this addItemToUniform "rhs_mag_zarya2";};
this addItemToVest "rhssaf_mag_br_m84";
this addItemToVest "rhssaf_mag_br_m75";
for "_i" from 1 to 10 do {this addItemToVest "rhs_10Rnd_762x54mmR_7N14";};

this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhs_1PN138";

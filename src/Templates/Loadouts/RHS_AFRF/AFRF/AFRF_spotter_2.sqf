removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["rhs_Booniehat_digi","rhs_beanie_green"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["G_Bandanna_oli","G_Balaclava_oli",""];
this addGoggles _RandomGoggles;
this forceAddUniform "rhs_uniform_gorka_r_g";
this addVest "rhs_6sh92_digi_headset";

this addWeapon "rhs_weap_ak74m_camo";
this addPrimaryWeaponItem "rhs_acc_dtk";
this addPrimaryWeaponItem "rhs_30Rnd_545x39_7N22_camo_AK";
this addWeapon "rhs_weap_pb_6p9";
this addHandgunItem "rhs_acc_6p9_suppressor";
this addHandgunItem "rhs_mag_9x18_8_57N181S";
this addWeapon "rhs_pdu4";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhs_acc_perst1ik";
this addItemToUniform "rhs_mag_nspn_red";
for "_i" from 1 to 3 do {this addItemToUniform "rhs_mag_9x18_8_57N181S";};
this addItemToVest "rhs_mag_rdg2_white";
this addItemToVest "rhs_mag_rgo";
this addItemToVest "rhs_mag_rgn";
this addItemToVest "O_R_IR_Grenade";
for "_i" from 1 to 4 do {this addItemToVest "rhs_30Rnd_545x39_7N22_camo_AK";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_30Rnd_545x39_7N10_2mag_camo_AK";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhs_1PN138";
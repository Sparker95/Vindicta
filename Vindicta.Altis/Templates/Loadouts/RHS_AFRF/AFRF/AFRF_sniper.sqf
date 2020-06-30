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
this addVest "rhs_6sh92_digi_radio";

this addWeapon "rhs_weap_t5000";
this addPrimaryWeaponItem "rhs_acc_dh520x56";
this addPrimaryWeaponItem "rhs_5Rnd_338lapua_t5000";
this addPrimaryWeaponItem "rhs_acc_harris_swivel";
this addWeapon "rhs_weap_pb_6p9";
this addHandgunItem "rhs_acc_6p9_suppressor";
this addHandgunItem "rhs_mag_9x18_8_57N181S";
this addWeapon "Binocular";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToUniform "rhs_mag_9x18_8_57N181S";};
for "_i" from 1 to 15 do {this addItemToVest "rhs_5Rnd_338lapua_t5000";};
this addItemToVest "O_R_IR_Grenade";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhs_1PN138";
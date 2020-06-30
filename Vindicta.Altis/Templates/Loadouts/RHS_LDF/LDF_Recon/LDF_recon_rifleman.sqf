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
this addVest "rhssaf_vest_md12_m70_rifleman";
this addBackpack "rhs_sidor";

this addWeapon "rhs_weap_ak103";
this addPrimaryWeaponItem "rhs_acc_dtk4screws";
this addPrimaryWeaponItem "rhs_acc_perst1ik";
this addPrimaryWeaponItem "rhs_75Rnd_762x39mm_tracer";
this addWeapon "rhs_weap_rpg26";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhs_acc_1pn93_1";
this addItemToUniform "I_E_IR_Grenade";
for "_i" from 1 to 2 do {this addItemToVest "rhs_30Rnd_762x39mm_polymer_U";};
for "_i" from 1 to 4 do {this addItemToVest "rhs_mag_zarya2";};
this addItemToVest "rhs_mag_rdg2_white";
this addItemToVest "rhs_mag_rgn";
this addItemToVest "rhs_mag_rgo";
for "_i" from 1 to 3 do {this addItemToBackpack "rhs_75Rnd_762x39mm_tracer";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "NVGoggles_OPFOR";
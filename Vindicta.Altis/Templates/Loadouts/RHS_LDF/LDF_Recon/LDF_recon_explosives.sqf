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
this addVest "rhssaf_vest_md12_digital";
this addBackpack "rhs_sidor";

this addWeapon "rhs_weap_ak104";
this addPrimaryWeaponItem "rhs_acc_dtk4screws";
this addPrimaryWeaponItem "rhs_acc_perst1ik";
this addPrimaryWeaponItem "rhs_30Rnd_762x39mm_polymer";
this addWeapon "rhs_weap_rshg2";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhs_acc_1pn93_1";
this addItemToUniform "I_E_IR_Grenade";
for "_i" from 1 to 2 do {this addItemToVest "rhs_charge_tnt_x2_mag";};
this addItemToVest "rhs_30Rnd_762x39mm_polymer";
for "_i" from 1 to 2 do {this addItemToVest "rhs_30Rnd_762x39mm_U";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_zarya2";};
this addItemToBackpack "SatchelCharge_Remote_Mag";
for "_i" from 1 to 2 do {this addItemToBackpack "DemoCharge_Remote_Mag";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "NVGoggles_OPFOR";
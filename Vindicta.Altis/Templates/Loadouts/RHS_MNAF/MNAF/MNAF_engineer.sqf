removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomUniform = selectRandom ["malden_uniform","mnaf_sweater"];
this forceaddUniform _RandomUniform;
_RandomHeadgear = selectRandom ["malden_bucket","H_Booniehat_khk","rhsusf_ach_bare_des","rhsusf_ach_bare_des_ess"];
this addHeadgear _RandomHeadgear;
this addVest "V_EOD_olive_F";
this addBackpack "B_FieldPack_cbr";

this addWeapon "rhs_weap_M590_8RD";
this addPrimaryWeaponItem "rhsusf_8Rnd_00Buck";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhsusf_8Rnd_00Buck";
this addItemToVest "rhsusf_8Rnd_00Buck";
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_8Rnd_Slug";};
this addItemToBackpack "ToolKit";
for "_i" from 1 to 2 do {this addItemToBackpack "DemoCharge_Remote_Mag";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_grenade_m15_mag";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_mag_an_m14_th3";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
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
this addBackpack "B_TacticalPack_blk";

this addWeapon "rhs_weap_m4a1_carryhandle";
this addPrimaryWeaponItem "rhsusf_acc_M952V";
this addPrimaryWeaponItem "rhs_mag_30Rnd_556x45_M855A1_Stanag";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhs_mag_30Rnd_556x45_M855A1_Stanag";
for "_i" from 1 to 3 do {this addItemToVest "rhs_mag_30Rnd_556x45_M855A1_Stanag";};
for "_i" from 1 to 2 do {this addItemToBackpack "DemoCharge_Remote_Mag";};
for "_i" from 1 to 4 do {this addItemToBackpack "rhs_grenade_m15_mag";};
this addItemToBackpack "SatchelCharge_Remote_Mag";
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_charge_tnt_x2_mag";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
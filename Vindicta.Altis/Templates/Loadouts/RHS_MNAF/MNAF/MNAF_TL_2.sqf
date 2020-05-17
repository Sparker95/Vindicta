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
_RandomHeadgear = selectRandom ["H_Booniehat_khk_hs","malden_cap","rhsusf_ach_bare_des_headset","rhsusf_ach_bare_des_headset_ess"];
this addHeadgear _RandomHeadgear;
this addVest "rhsusf_spc_squadleader";

this addWeapon "rhs_weap_m16a4_carryhandle";
this addPrimaryWeaponItem "rhsusf_acc_anpeq15side_bk";
this addPrimaryWeaponItem "rhsusf_acc_ACOG_USMC";
this addPrimaryWeaponItem "rhs_mag_30Rnd_556x45_M855A1_Stanag";
this addPrimaryWeaponItem "rhsusf_acc_kac_grip";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_mkii_mag";};
for "_i" from 1 to 4 do {this addItemToVest "rhs_mag_30Rnd_556x45_M855A1_Stanag_Tracer_Red";};
this addItemToVest "rhs_grenade_mki_mag";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_30Rnd_556x45_M855A1_Stanag";};
this addItemToVest "rhs_mag_an_m8hc";
this addItemToVest "rhs_mag_m18_green";
this addItemToVest "rhs_mag_m18_red";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhsusf_ANPVS_14";
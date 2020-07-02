removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["rhsgref_helmet_pasgt_olive","FGN_AAF_PASGT_M81","FGN_AAF_PASGT_M81_ESS", "FGN_AAF_PASGT_M81_ESS_2"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag_green","G_Bandanna_oli","",""];
this addGoggles _RandomGoggles;
this addVest "FGN_AAF_M99Vest_M81_Rifleman_Radio";
this forceaddUniform "rhsgref_uniform_olive";

this addWeapon "rhs_weap_m16a4_carryhandle";
this addPrimaryWeaponItem "rhsusf_acc_anpeq15side_bk";
_RandomSight = selectRandom ["rhsusf_acc_ACOG_USMC", ""];
this addPrimaryWeaponItem _RandomSight;
this addPrimaryWeaponItem "rhs_mag_30Rnd_556x45_M855A1_Stanag";
this addPrimaryWeaponItem "rhsusf_acc_kac_grip";
this addWeapon "Binocular";

this addItemToUniform "FirstAidKit";
this addItemToUniform "FGN_AAF_PatrolCap_M81";
this addItemToUniform "Chemlight_blue";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_30Rnd_556x45_M855A1_Stanag_Tracer_Red";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_30Rnd_556x45_M855A1_Stanag";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_mkii_mag";};
this addItemToVest "rhs_grenade_mki_mag";
this addItemToVest "rhs_mag_an_m8hc";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhsusf_ANPVS_14";
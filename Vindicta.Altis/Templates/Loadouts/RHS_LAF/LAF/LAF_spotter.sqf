removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomGoggles = selectRandom ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag_green","G_Bandanna_oli","",""];
this addGoggles _RandomGoggles;
this forceAddUniform "FGN_FIA_M10_M81_DB";
this addVest "V_I_G_resistanceLeader_F";
this addHeadgear "FGN_AAF_Boonie_M81";

this addWeapon "rhs_weap_m16a4_imod";
this addPrimaryWeaponItem "rhsusf_acc_SF3P556";
this addPrimaryWeaponItem "rhsusf_acc_anpeq15side_bk";
this addPrimaryWeaponItem "rhsusf_acc_ACOG_RMR";
this addPrimaryWeaponItem "rhs_mag_30Rnd_556x45_Mk318_Stanag";
this addPrimaryWeaponItem "rhsusf_acc_harris_bipod";
this addWeapon "rhs_weap_cz99";
this addHandgunItem "rhssaf_mag_15Rnd_9x19_FMJ";
this addWeapon "rhsusf_bino_lrf_Vector21";

this addItemToUniform "FirstAidKit";
this addItemToUniform "B_IR_Grenade";
for "_i" from 1 to 2 do {this addItemToUniform "rhssaf_mag_15Rnd_9x19_FMJ";};
this addItemToVest "rhs_grenade_mki_mag";
this addItemToVest "rhs_grenade_mkii_mag";
for "_i" from 1 to 6 do {this addItemToVest "rhs_mag_30Rnd_556x45_Mk318_Stanag";};
this addItemToVest "rhs_mag_an_m8hc";
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhsusf_ANPVS_14";
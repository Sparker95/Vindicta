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

this addWeapon "rhs_weap_XM2010_wd";
this addPrimaryWeaponItem "rhsusf_acc_M2010S_wd";
this addPrimaryWeaponItem "rhsusf_acc_anpeq15side_bk";
this addPrimaryWeaponItem "rhsusf_acc_premier";
this addPrimaryWeaponItem "rhsusf_5Rnd_300winmag_xm2010";
this addPrimaryWeaponItem "rhsusf_acc_harris_bipod";
this addWeapon "rhs_weap_cz99";
this addHandgunItem "rhssaf_mag_15Rnd_9x19_FMJ";
this addWeapon "Binocular";

this addItemToUniform "FirstAidKit";
this addItemToUniform "B_IR_Grenade";
for "_i" from 1 to 2 do {this addItemToUniform "rhssaf_mag_15Rnd_9x19_FMJ";};
this addItemToVest "rhsusf_acc_premier_anpvs27";
for "_i" from 1 to 20 do {this addItemToVest "rhsusf_5Rnd_300winmag_xm2010";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhsusf_ANPVS_14";
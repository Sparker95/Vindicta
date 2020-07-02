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

this addWeapon "rhs_weap_m40a5";
this addPrimaryWeaponItem "rhsusf_acc_anpeq15side_bk";
this addPrimaryWeaponItem "rhsusf_acc_premier";
this addPrimaryWeaponItem "rhsusf_5Rnd_762x51_AICS_m118_special_Mag";
this addPrimaryWeaponItem "rhsusf_acc_harris_swivel";
this addWeapon "rhs_weap_cz99";
this addHandgunItem "rhssaf_mag_15Rnd_9x19_FMJ";
this addWeapon "Binocular";

this addItemToUniform "FirstAidKit";
this addItemToUniform "B_IR_Grenade";
this addItemToVest "rhsusf_acc_premier_anpvs27";
for "_i" from 1 to 2 do {this addItemToUniform "rhssaf_mag_15Rnd_9x19_FMJ";};
for "_i" from 1 to 4 do {this addItemToVest "rhsusf_10Rnd_762x51_m118_special_Mag";};
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_10Rnd_762x51_m62_Mag";};
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_10Rnd_762x51_m993_Mag";};
for "_i" from 1 to 6 do {this addItemToVest "rhsusf_5Rnd_762x51_AICS_m118_special_Mag";};
for "_i" from 1 to 4 do {this addItemToVest "rhsusf_5Rnd_762x51_AICS_m993_Mag";};
for "_i" from 1 to 6 do {this addItemToVest "rhsusf_5Rnd_762x51_AICS_m62_Mag";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhsusf_ANPVS_14";
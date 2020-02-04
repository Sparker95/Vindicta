removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["FGN_AAF_PASGT","FGN_AAF_PASGT_ESS","FGN_AAF_PASGT_ESS_2","FGN_AAF_PASGT_Type07","FGN_AAF_PASGT_Type07_ESS","FGN_AAF_PASGT_Type07_ESS_2"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","","",""];
this addGoggles _RandomGoggles;
this forceAddUniform "FGN_AAF_M10_Type07_Summer";
this addVest "FGN_AAF_CIRAS_MM";

this addWeapon "rhs_weap_SCARH_FDE_STD_grip3";
this addPrimaryWeaponItem "rhsusf_acc_su230a_c";
this addPrimaryWeaponItem "rhs_mag_20Rnd_SCAR_762x51_m80a1_epr";
this addPrimaryWeaponItem "rhsusf_acc_grip2";
this addWeapon "rhssaf_zrak_rd7j";

this addItemToUniform "FirstAidKit";
this addItemToUniform "FGN_AAF_PatrolCap_Type07";
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_mkii_mag";};
this addItemToVest "rhs_mag_20Rnd_SCAR_762x51_m61_ap";
for "_i" from 1 to 4 do {this addItemToVest "rhs_mag_20Rnd_SCAR_762x51_m80a1_epr";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
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
this forceaddUniform "FGN_AAF_M10_Type07_Summer";
this addVest "FGN_AAF_CIRAS_MM";
this addBackpack "B_LegStrapBag_coyote_F";

this addWeapon "rhs_weap_l1a1";
this addPrimaryWeaponItem "rhsgref_acc_falMuzzle_l1a1";
this addPrimaryWeaponItem "rhsgref_acc_l1a1_l2a2_3d";
this addPrimaryWeaponItem "rhs_mag_20Rnd_762x51_m80a1_fnfal";

this addItemToUniform "FirstAidKit";
this addItemToUniform "FGN_AAF_PatrolCap_Type07";
for "_i" from 1 to 4 do {this addItemToVest "rhs_mag_20Rnd_762x51_m80a1_fnfal";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_mkii_mag";};
this addItemToBackpack "rhsgref_acc_l1a1_anpvs2";
for "_i" from 1 to 4 do {this addItemToBackpack "rhs_mag_20Rnd_762x51_m62_fnfal";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
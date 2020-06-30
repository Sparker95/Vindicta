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
this addVest "FGN_AAF_BallisticVest_Coyote";
this addBackpack "FGN_AAF_UMTBS_Type07_Engineer";

this addWeapon "FGN_AAF_Mossberg590A1";
this addPrimaryWeaponItem "rhsusf_8Rnd_00Buck";

this addItemToUniform "FirstAidKit";
this addItemToUniform "FGN_AAF_PatrolCap_Type07";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_an_m14_th3";};
this addItemToBackpack "ToolKit";
for "_i" from 1 to 4 do {this addItemToBackpack "rhsusf_8Rnd_00Buck";};
for "_i" from 1 to 4 do {this addItemToBackpack "rhsusf_8Rnd_Slug";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
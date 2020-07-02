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
this addVest "FGN_AAF_CIRAS_MG";
this addBackpack "B_LegStrapBag_coyote_F";

this addWeapon "rhs_weap_mg42";
this addPrimaryWeaponItem "rhsgref_296Rnd_792x57_SmK_alltracers_belt";
this forceaddUniform "FGN_AAF_M10_Type07_Summer";
this addVest "FGN_AAF_CIRAS_MG";
this addBackpack "B_LegStrapBag_coyote_F";

this addItemToUniform "FirstAidKit";
this addItemToUniform "FGN_AAF_PatrolCap_Type07";
this addItemToVest "rhsgref_296Rnd_792x57_SmK_alltracers_belt";
for "_i" from 1 to 4 do {this addItemToBackpack "rhsgref_50Rnd_792x57_SmK_alltracers_drum";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
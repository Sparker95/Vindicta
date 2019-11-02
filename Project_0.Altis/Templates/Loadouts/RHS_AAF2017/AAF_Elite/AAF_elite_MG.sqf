removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = ["FGN_AAF_PASGT_Type07","FGN_AAF_PASGT_Type07_ESS","FGN_AAF_PASGT_Type07_ESS_2"] call BIS_fnc_selectRandom;
this addHeadgear _RandomHeadgear;
_RandomGoggles = ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","","","",""] call BIS_fnc_selectRandom;
this addGoggles _RandomGoggles;
this forceAddUniform "FGN_AAF_M10_Type07_Summer";
this addVest "FGN_AAF_CIRAS_MG";
this addBackpack "FGN_AAF_Bergen_Type07";

this addWeapon "rhs_weap_pkp";

this addItemToUniform "FirstAidKit";
this addItemToUniform "FGN_AAF_PatrolCap_Type07";
for "_i" from 1 to 2 do {this addItemToVest "rhs_100Rnd_762x54mmR_green";};
this addItemToBackpack "rhs_100Rnd_762x54mmR_7BZ3";
this addItemToBackpack "rhs_100Rnd_762x54mmR_green";
this addHeadgear "FGN_AAF_PASGT_Type07";

this linkItem "ItemWatch";
this linkItem "ItemRadio";

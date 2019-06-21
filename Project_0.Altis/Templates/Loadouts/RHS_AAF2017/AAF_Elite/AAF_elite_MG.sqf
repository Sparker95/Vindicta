

removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this forceAddUniform "FGN_AAF_M10_Type07_Summer";
this addItemToUniform "FirstAidKit";
this addVest "FGN_AAF_CIRAS_MG";
for "_i" from 1 to 2 do {this addItemToVest "rhs_100Rnd_762x54mmR";};
this addBackpack "FGN_AAF_Bergen_Type07";
this addItemToBackpack "rhs_100Rnd_762x54mmR";
_RandomHeadgear = ["FGN_AAF_PASGT_Type07","FGN_AAF_PASGT_Type07_ESS","FGN_AAF_PASGT_Type07_ESS_2"] call BIS_fnc_selectRandom;  
  

this addHeadgear _RandomHeadgear;
_RandomGoggles = ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","","","",""] call BIS_fnc_selectRandom;  
  

this addGoggles _RandomGoggles;

this addWeapon "rhs_weap_pkp";
this addItemToBackpack "rhs_100Rnd_762x54mmR";

this linkItem "ItemWatch";
this linkItem "ItemRadio";

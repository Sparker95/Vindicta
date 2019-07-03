
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
this addVest "FGN_AAF_CIRAS_MM";
for "_i" from 1 to 3 do {this addItemToVest "rhsusf_mag_17Rnd_9x19_JHP";};
for "_i" from 1 to 8 do {this addItemToVest "rhs_10Rnd_762x54mmR_7N1";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_f1";};
_RandomHeadgear = ["FGN_AAF_PASGT_Type07","FGN_AAF_PASGT_Type07_ESS","FGN_AAF_PASGT_Type07_ESS_2"] call BIS_fnc_selectRandom;  
  

this addHeadgear _RandomHeadgear;
_RandomGoggles = ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","","","",""] call BIS_fnc_selectRandom;  
  

this addGoggles _RandomGoggles;

this addWeapon "rhs_weap_svdp";
this addPrimaryWeaponItem "rhs_acc_pso1m2";
this addWeapon "rhsusf_weap_glock17g4";

this linkItem "ItemWatch";
this linkItem "ItemRadio";

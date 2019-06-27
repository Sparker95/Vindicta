

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
_RandomVest = ["FGN_AAF_CIRAS_SAW","FGN_AAF_CIRAS_SAW_Belt","FGN_AAF_CIRAS_SAW_Belt_CamB","FGN_AAF_CIRAS_SAW_CamB"] call BIS_fnc_selectRandom;  
  

this addVest _RandomVest;
for "_i" from 1 to 3 do {this addItemToVest "rhsusf_200rnd_556x45_mixed_box";};
this addItemToVest "rhs_mag_an_m8hc";
this addBackpack "FGN_AAF_UMTBS_Type07";
for "_i" from 1 to 2 do {this addItemToBackpack "rhsusf_200rnd_556x45_mixed_box";};
_RandomHeadgear = ["FGN_AAF_PASGT_Type07","FGN_AAF_PASGT_Type07_ESS","FGN_AAF_PASGT_Type07_ESS_2"] call BIS_fnc_selectRandom;  
  

this addHeadgear _RandomHeadgear;
_RandomGoggles = ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","","","",""] call BIS_fnc_selectRandom;  
  

this addGoggles _RandomGoggles;

this addWeapon "rhs_weap_m249";

this linkItem "ItemWatch";
this linkItem "ItemRadio";

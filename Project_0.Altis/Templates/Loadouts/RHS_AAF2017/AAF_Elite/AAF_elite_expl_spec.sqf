

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
this addVest "FGN_AAF_CIRAS_Engineer";
for "_i" from 1 to 6 do {this addItemToVest "rhsgref_30rnd_556x45_m21";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_f1";};
this addItemToVest "rhs_mag_an_m8hc";
for "_i" from 1 to 2 do {this addItemToVest "rhssaf_mag_brz_m88";};
_RandomVest = ["FGN_AAF_CIRAS_Engineer","FGN_AAF_CIRAS_Engineer_CamB"] call BIS_fnc_selectRandom;  
  

this addVest _RandomVest;
for "_i" from 1 to 2 do {this addItemToBackpack "DemoCharge_Remote_Mag";};
for "_i" from 1 to 2 do {this addItemToBackpack "ClaymoreDirectionalMine_Remote_Mag";};
this addItemToBackpack "SatchelCharge_Remote_Mag";
_RandomHeadgear = ["FGN_AAF_PASGT_Type07","FGN_AAF_PASGT_Type07_ESS","FGN_AAF_PASGT_Type07_ESS_2"] call BIS_fnc_selectRandom;  
  

this addHeadgear _RandomHeadgear;
_RandomGoggles = ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","","","",""] call BIS_fnc_selectRandom;  
  

this addGoggles _RandomGoggles;


this addWeapon "rhs_weap_m21a";
this addPrimaryWeaponItem "rhs_acc_2dpZenit";

this linkItem "ItemWatch";
this linkItem "ItemRadio";




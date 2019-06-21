
removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this forceAddUniform "FGN_AAF_M10_Type07";
this addItemToUniform "FirstAidKit";
this addItemToUniform "rhs_1PN138";
_RandomVest = ["FGN_AAF_CIRAS_Engineer","FGN_AAF_CIRAS_Engineer_CamB"] call BIS_fnc_selectRandom;  
this addVest _RandomVest;
  
 
this addItemToVest "rhs_mag_an_m8hc";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_zarya2";};
for "_i" from 1 to 8 do {this addItemToVest "rhssaf_30rnd_556x45_EPR_G36";};
this addItemToVest "rhssaf_mag_brz_m88";
this addBackpack "FGN_AAF_UMTBS_Type07_Engineer";
this addItemToBackpack "SatchelCharge_Remote_Mag";
for "_i" from 1 to 4 do {this addItemToBackpack "DemoCharge_Remote_Mag";};
this addItemToBackpack "rhssaf_mag_brz_m88";
_RandomHeadgear = ["FGN_AAF_Boonie_Type07","rhsusf_opscore_mar_ut","rhsusf_opscore_mar_ut_pelt"] call BIS_fnc_selectRandom;  
  

this addHeadgear _RandomHeadgear;
_RandomGoggles = ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","rhsusf_oakley_goggles_blk","",""] call BIS_fnc_selectRandom;  
  

this addGoggles _RandomGoggles;


this addWeapon "rhs_weap_g36kv";
this addPrimaryWeaponItem "rhs_acc_perst3";
this addPrimaryWeaponItem "rhsusf_acc_eotech_xps3";

this linkItem "ItemWatch";
this linkItem "ItemRadio";


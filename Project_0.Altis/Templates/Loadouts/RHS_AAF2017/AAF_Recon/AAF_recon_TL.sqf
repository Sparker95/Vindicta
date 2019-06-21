
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
this addItemToUniform "rhssaf_30rnd_556x45_EPR_G36";
_RandomVest = ["FGN_AAF_CIRAS_TL","FGN_AAF_CIRAS_TL_CamB"] call BIS_fnc_selectRandom;  
  

this addVest _RandomVest;
for "_i" from 1 to 3 do {this addItemToVest "rhsusf_mag_17Rnd_9x19_JHP";};
this addItemToVest "rhs_mag_an_m8hc";
for "_i" from 1 to 6 do {this addItemToVest "rhssaf_30rnd_556x45_EPR_G36";};
for "_i" from 1 to 2 do {this addItemToVest "rhssaf_30rnd_556x45_Tracers_G36";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_zarya2";};
for "_i" from 1 to 2 do {this addItemToVest "rhssaf_mag_brz_m88";};
for "_i" from 1 to 2 do {this addItemToVest "rhssaf_mag_rshb_p98";};
this addBackpack "FGN_AAF_Bergen_SL_Type07";
_RandomHeadgear = ["FGN_AAF_Boonie_Type07","rhsusf_opscore_mar_ut","rhsusf_opscore_mar_ut_pelt"] call BIS_fnc_selectRandom;  
  

this addHeadgear _RandomHeadgear;
_RandomGoggles = ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","rhsusf_oakley_goggles_blk","",""] call BIS_fnc_selectRandom;  
  

this addGoggles _RandomGoggles;


this addWeapon "rhs_weap_g36c";
this addPrimaryWeaponItem "rhs_acc_perst3";
this addPrimaryWeaponItem "rhsusf_acc_eotech_xps3";
this addWeapon "rhsusf_weap_glock17g4";
this addHandgunItem "acc_flashlight_pistol";
this addWeapon "Binocular";

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";


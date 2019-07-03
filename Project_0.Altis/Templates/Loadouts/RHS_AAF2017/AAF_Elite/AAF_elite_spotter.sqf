
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
this addItemToUniform "rhs_1PN138";
this addVest "FGN_AAF_CIRAS_RF01";
for "_i" from 1 to 6 do {this addItemToVest "rhssaf_30rnd_556x45_EPR_G36";};
for "_i" from 1 to 2 do {this addItemToVest "rhssaf_30rnd_556x45_Tracers_G36";};
for "_i" from 1 to 3 do {this addItemToVest "rhsusf_mag_17Rnd_9x19_JHP";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_f1";};
this addItemToVest "rhs_mag_an_m8hc";
this addBackpack "FGN_AAF_Bergen_Radio_Type07";
for "_i" from 1 to 2 do {this addItemToBackpack "APERSTripMine_Wire_Mag";};
_RandomGoggles = ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","","","",""] call BIS_fnc_selectRandom;  
  

this addGoggles _RandomGoggles;
_RandomHeadgear = ["FGN_AAF_Boonie_Type07","rhsusf_bowman_cap"] call BIS_fnc_selectRandom;  
  

this addHeadgear _RandomHeadgear;


this addWeapon "rhs_weap_g36kv";
this addPrimaryWeaponItem "rhs_acc_2dpZenit_ris";
this addPrimaryWeaponItem "rhsusf_acc_eotech_xps3";
this addWeapon "rhsusf_weap_glock17g4";
this addHandgunItem "acc_flashlight_pistol";
this addWeapon "rhs_pdu4";

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";


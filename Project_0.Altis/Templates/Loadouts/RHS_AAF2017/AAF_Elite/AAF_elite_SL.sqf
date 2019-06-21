
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
this addVest "FGN_AAF_CIRAS_SL";
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_mag_17Rnd_9x19_JHP";};
for "_i" from 1 to 5 do {this addItemToVest "rhsgref_30rnd_556x45_m21";};
this addItemToVest "rhsgref_30rnd_556x45_m21_t";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_f1";};
this addBackpack "FGN_AAF_Bergen_SL_Type07";
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_mag_nspd";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_mag_an_m8hc";};
this addItemToBackpack "rhs_mag_m18_yellow";
this addItemToBackpack "rhs_mag_m18_red";
this addItemToBackpack "rhs_mag_m18_purple";
this addItemToBackpack "rhs_mag_m18_green";
_RandomHeadgear = ["FGN_AAF_PASGT_Type07","FGN_AAF_PASGT_Type07_ESS","FGN_AAF_PASGT_Type07_ESS_2"] call BIS_fnc_selectRandom;  
  

this addHeadgear _RandomHeadgear;
_RandomGoggles = ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","","","",""] call BIS_fnc_selectRandom;  
  

this addGoggles _RandomGoggles;

this addWeapon "rhs_weap_m21s";
this addPrimaryWeaponItem "rhs_acc_2dpZenit";
this addPrimaryWeaponItem "rhs_acc_pkas";
this addWeapon "rhsusf_weap_glock17g4";
this addHandgunItem "acc_flashlight_pistol";
this addWeapon "Binocular";

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "ItemGPS";



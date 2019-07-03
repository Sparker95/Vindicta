
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
this addItemToUniform "rhsusf_5Rnd_762x51_m118_special_Mag";
this addVest "FGN_AAF_CIRAS_MM";
for "_i" from 1 to 3 do {this addItemToVest "rhsusf_mag_17Rnd_9x19_JHP";};
this addItemToVest "rhs_mag_an_m8hc";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_zarya2";};
for "_i" from 1 to 9 do {this addItemToVest "rhsusf_5Rnd_762x51_m118_special_Mag";};
for "_i" from 1 to 5 do {this addItemToVest "rhsusf_5Rnd_762x51_m993_Mag";};
_RandomHeadgear = ["FGN_AAF_Boonie_Type07","rhsusf_opscore_mar_ut","rhsusf_opscore_mar_ut_pelt"] call BIS_fnc_selectRandom;  
  

this addHeadgear _RandomHeadgear;
this addGoggles "rhs_scarf";

this addWeapon "rhs_weap_m24sws";
this addPrimaryWeaponItem "rhsusf_acc_m24_silencer_black";
this addPrimaryWeaponItem "rhsusf_acc_M8541_low";
this addPrimaryWeaponItem "rhsusf_acc_harris_swivel";
this addWeapon "rhsusf_weap_glock17g4";
this addHandgunItem "acc_flashlight_pistol";
this addWeapon "Binocular";

this linkItem "ItemWatch";
this linkItem "ItemRadio";


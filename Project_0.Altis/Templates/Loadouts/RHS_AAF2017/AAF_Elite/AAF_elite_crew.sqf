
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
this addVest "FGN_AAF_M99Vest_Khaki_Radio";
for "_i" from 1 to 4 do {this addItemToVest "rhsgref_20rnd_765x17_vz61";};
this addItemToVest "rhs_mag_f1";
this addItemToVest "rhs_mag_an_m8hc";
_RandomHeadgear = ["rhsusf_cvc_green_alt_helmet","rhsusf_cvc_green_ess"] call BIS_fnc_selectRandom;  
  
this addHeadgear _RandomHeadgear;

_RandomGoggles = ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhsusf_shemagh2_od","rhsusf_shemagh_od","","",""] call BIS_fnc_selectRandom;  
  

this addGoggles _RandomGoggles;

this addWeapon "rhs_weap_savz61";
this addWeapon "Binocular";


this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";




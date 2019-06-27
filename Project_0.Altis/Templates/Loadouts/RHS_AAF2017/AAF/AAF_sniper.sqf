



removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this forceAddUniform "FGN_AAF_M93_Lizard";
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "rhsgref_10Rnd_792x57_m76";};
this addVest "FGN_AAF_M99Vest_Lizard";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_rgd5";};
for "_i" from 1 to 7 do {this addItemToVest "rhsgref_10Rnd_792x57_m76";};
for "_i" from 1 to 3 do {this addItemToVest "rhs_mag_762x25_8";};
_RandomGoggles = ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","","","",""] call BIS_fnc_selectRandom;  
  

this addGoggles _RandomGoggles;
_RandomHeadgear = ["FGN_AAF_Boonie_Lizard","H_Bandanna_khk_hs","H_Bandanna_khk"] call BIS_fnc_selectRandom;  
  

this addHeadgear _RandomHeadgear;

this addWeapon "rhs_weap_m76";
this addPrimaryWeaponItem "rhs_acc_pso1m2";
this addWeapon "rhs_weap_tt33";

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";

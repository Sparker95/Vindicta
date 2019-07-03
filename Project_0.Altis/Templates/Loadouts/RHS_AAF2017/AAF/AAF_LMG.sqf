


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
this addVest "FGN_AAF_M99Vest_Lizard";
for "_i" from 1 to 2 do {this addItemToVest "rhs_75Rnd_762x39mm_tracer";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_rgd5";};
this addBackpack "FGN_AAF_Fieldpack_Lizard";
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_75Rnd_762x39mm_tracer";};
_RandomHeadgear = ["FGN_AAF_Cap_Lizard","FGN_AAF_PASGT_Lizard","FGN_AAF_PASGT_Lizard_ESS","FGN_AAF_PASGT_Lizard_ESS_2","rhsgref_helmet_pasgt_olive"] call BIS_fnc_selectRandom;  
  

this addHeadgear _RandomHeadgear;
_RandomGoggles = ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","","","",""] call BIS_fnc_selectRandom;  
  

this addGoggles _RandomGoggles;


this addWeapon "rhs_weap_pm63";
this addPrimaryWeaponItem "rhs_acc_dtkakm";
this addPrimaryWeaponItem "rhs_acc_2dpZenit";

this linkItem "ItemWatch";

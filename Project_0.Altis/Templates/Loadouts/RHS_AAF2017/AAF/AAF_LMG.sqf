removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = ["FGN_AAF_Cap_Lizard","FGN_AAF_PASGT_Lizard","FGN_AAF_PASGT_Lizard_ESS","FGN_AAF_PASGT_Lizard_ESS_2","rhsgref_helmet_pasgt_olive"] call BIS_fnc_selectRandom;
this addHeadgear _RandomHeadgear;
_RandomGoggles = ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","","","",""] call BIS_fnc_selectRandom;
this addGoggles _RandomGoggles;
this forceAddUniform "FGN_AAF_M93_Lizard";
this addVest "FGN_AAF_M99Vest_Lizard";
this addBackpack "FGN_AAF_Fieldpack_Lizard";

this addWeapon "rhs_weap_pm63";
this addPrimaryWeaponItem "rhs_acc_dtkakm";
this addPrimaryWeaponItem "rhs_acc_2dpZenit";
this addPrimaryWeaponItem "rhs_75Rnd_762x39mm_tracer";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToBackpack "rhs_75Rnd_762x39mm_tracer";};
this addHeadgear "FGN_AAF_PASGT_Lizard";

this linkItem "ItemWatch";

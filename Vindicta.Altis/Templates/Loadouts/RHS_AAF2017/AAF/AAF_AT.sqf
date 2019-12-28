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
this addVest "FGN_AAF_M99Vest_Lizard_Rifleman";
this addBackpack "rhs_rpg_empty";

this addWeapon "rhs_weap_akm";
this addPrimaryWeaponItem "rhs_acc_dtkakm";
this addPrimaryWeaponItem "rhs_acc_2dpZenit";
this addWeapon "rhs_weap_rpg7";
this addSecondaryWeaponItem "rhs_acc_pgo7v3";
this addSecondaryWeaponItem "rhs_rpg7_PG7VL_mag";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhs_30Rnd_762x39mm";
for "_i" from 1 to 4 do {this addItemToVest "rhs_30Rnd_762x39mm";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_mkii_mag";};
for "_i" from 1 to 3 do {this addItemToBackpack "rhs_rpg7_PG7VL_mag";};

this linkItem "ItemWatch";

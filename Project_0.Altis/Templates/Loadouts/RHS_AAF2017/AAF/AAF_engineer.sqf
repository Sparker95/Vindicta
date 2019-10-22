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
this addBackpack "FGN_AAF_TacticalBackpack_Lizard";

this addWeapon "FGN_AAF_Mossberg590A1";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "rhsusf_8Rnd_00Buck";};
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_8Rnd_Slug";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_mkii_mag";};
this addItemToBackpack "ToolKit";
for "_i" from 1 to 2 do {this addItemToBackpack "rhsusf_8Rnd_00Buck";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhsusf_8Rnd_Slug";};

this linkItem "ItemWatch";

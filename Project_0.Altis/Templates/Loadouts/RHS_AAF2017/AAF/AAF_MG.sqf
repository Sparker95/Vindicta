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

this addWeapon "rhs_weap_pkm";

this addItemToUniform "FirstAidKit";
this addItemToVest "rhs_100Rnd_762x54mmR";
for "_i" from 1 to 3 do {this addItemToBackpack "rhs_100Rnd_762x54mmR";};

this linkItem "ItemWatch";

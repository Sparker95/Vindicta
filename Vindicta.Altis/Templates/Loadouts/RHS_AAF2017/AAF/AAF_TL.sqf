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
this addVest "FGN_AAF_M99Vest_Lizard_Rifleman_Radio";

this addWeapon "rhs_weap_akm_zenitco01_b33";
this addPrimaryWeaponItem "rhs_acc_dtkakm";
this addPrimaryWeaponItem "rhs_acc_2dpZenit_ris";
this addPrimaryWeaponItem "rhs_acc_rakursPM";
this addPrimaryWeaponItem "rhs_30Rnd_762x39mm";
this addPrimaryWeaponItem "rhsusf_acc_kac_grip";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhs_30Rnd_762x39mm_tracer";
for "_i" from 1 to 3 do {this addItemToVest "rhs_30Rnd_762x39mm";};
this addItemToVest "rhs_grenade_mkii_mag";
this addItemToVest "rhs_grenade_anm8_mag";
this addItemToVest "rhs_30Rnd_762x39mm_tracer";

this linkItem "ItemWatch";
this linkItem "ItemRadio";

removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = ["rhs_tsh4","rhs_tsh4_bala","rhs_tsh4_ess","rhs_tsh4_ess_bala"] call BIS_fnc_selectRandom;
this addHeadgear _RandomHeadgear;
_RandomGoggles = ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhsusf_shemagh2_od","rhsusf_shemagh_od","","",""] call BIS_fnc_selectRandom;
this addGoggles _RandomGoggles;
this forceAddUniform "FGN_AAF_M10_Type07_Summer";
this addVest "FGN_AAF_CIRAS_Empty";

this addWeapon "rhs_weap_savz61";
this addPrimaryWeaponItem "rhsgref_20rnd_765x17_vz61";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 6 do {this addItemToVest "rhsgref_20rnd_765x17_vz61";};
this addItemToVest "rhs_grenade_anm8_mag";

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

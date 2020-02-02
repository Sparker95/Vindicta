removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["rhs_tsh4","rhs_tsh4_bala","rhs_tsh4_ess","rhs_tsh4_ess_bala"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","","",""];
this addGoggles _RandomGoggles;
this forceAddUniform "U_Tank_green_F";
this addVest "FGN_AAF_CIRAS_Crew";

this addWeapon "rhs_weap_m21s_fold";
this addPrimaryWeaponItem "rhsgref_30rnd_556x45_m21";
this addWeapon "rhs_weap_tt33";
this addHandgunItem "rhs_mag_762x25_8";

this addItemToUniform "FirstAidKit";
this addItemToVest "rhs_grenade_anm8_mag";
for "_i" from 1 to 2 do {this addItemToVest "rhsgref_30rnd_556x45_m21";};
this addItemToVest "rhs_mag_762x25_8";
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";



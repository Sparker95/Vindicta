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
_RandomGoggles = selectRandom ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","","","",""];
this addGoggles _RandomGoggles;
this forceaddUniform "U_Tank_green_F";
this addVest "rhs_vest_pistol_holster";

this addWeapon "rhs_weap_savz61";
this addPrimaryWeaponItem "rhsgref_20rnd_765x17_vz61";
this addWeapon "Binocular";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhs_grenade_anm8_mag";
for "_i" from 1 to 2 do {this addItemToVest "rhsgref_20rnd_765x17_vz61";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemRadio";

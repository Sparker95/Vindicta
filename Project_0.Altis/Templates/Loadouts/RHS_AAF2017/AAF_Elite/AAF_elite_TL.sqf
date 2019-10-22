removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomVest = ["FGN_AAF_CIRAS_TL","FGN_AAF_CIRAS_TL_CamB"] call BIS_fnc_selectRandom;
this addVest _RandomVest;
_RandomHeadgear = ["FGN_AAF_PASGT_Type07","FGN_AAF_PASGT_Type07_ESS","FGN_AAF_PASGT_Type07_ESS_2"] call BIS_fnc_selectRandom;
this addHeadgear _RandomHeadgear;
_RandomGoggles = ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","","","",""] call BIS_fnc_selectRandom;
this addGoggles _RandomGoggles;
this forceAddUniform "FGN_AAF_M10_Type07_Summer";

this addWeapon "rhs_weap_m21a";
this addPrimaryWeaponItem "rhs_acc_perst1ik";
this addPrimaryWeaponItem "rhs_acc_pkas";
this addWeapon "rhsusf_weap_glock17g4";
this addHandgunItem "acc_flashlight_pistol";
this addWeapon "rhssaf_zrak_rd7j";

this addItemToUniform "FirstAidKit";
this addItemToUniform "FGN_AAF_PatrolCap_Type07";
this addItemToUniform "rhs_acc_2dpZenit";
for "_i" from 1 to 5 do {this addItemToVest "rhsgref_30rnd_556x45_m21";};
for "_i" from 1 to 3 do {this addItemToVest "rhsusf_mag_17Rnd_9x19_JHP";};
for "_i" from 1 to 2 do {this addItemToVest "rhsgref_30rnd_556x45_m21_t";};
this addItemToVest "rhs_grenade_anm8_mag";
this addItemToVest "rhs_grenade_mki_mag";
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_mkii_mag";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_mkiiia1_mag";};

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhs_1PN138";

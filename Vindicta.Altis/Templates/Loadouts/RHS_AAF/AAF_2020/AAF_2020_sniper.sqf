removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomGoggles = selectRandom ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","","",""];
this addGoggles _RandomGoggles;
_RandomHeadgear = selectRandom ["FGN_AAF_Boonie_Type07","FGN_AAF_Boonie_Type07","rhsusf_bowman_cap"];
this addHeadgear _RandomHeadgear;
this forceaddUniform "FGN_AAF_M10_Type07_Summer";
this addVest "FGN_AAF_CIRAS_MM";

this addWeapon "rhs_weap_t5000";
this addPrimaryWeaponItem "rhs_acc_dh520x56";
this addPrimaryWeaponItem "rhs_5Rnd_338lapua_t5000";
this addPrimaryWeaponItem "rhs_acc_harris_swivel";
this addWeapon "rhsusf_weap_glock17g4";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "rhsusf_mag_17Rnd_9x19_JHP";
this addWeapon "Binocular";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 8 do {this addItemToVest "rhs_5Rnd_338lapua_t5000";};
for "_i" from 1 to 3 do {this addItemToVest "rhsusf_mag_17Rnd_9x19_JHP";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_mkii_mag";};
this addItemToVest "rhs_grenade_mki_mag";
this addItemToVest "rhs_grenade_anm8_mag";
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "NVGoggles_OPFOR";
removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomGoggles = ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","","","",""] call BIS_fnc_selectRandom;
this addGoggles _RandomGoggles;
_RandomHeadgear = ["FGN_AAF_Boonie_Type07","rhsusf_bowman_cap"] call BIS_fnc_selectRandom;
this addHeadgear _RandomHeadgear;
this forceAddUniform "FGN_AAF_M10_Type07_Summer";
this addVest "FGN_AAF_CIRAS_RF01";
this addBackpack "FGN_AAF_Bergen_Radio_Type07";

this addWeapon "rhs_weap_g36kv";
this addPrimaryWeaponItem "rhsusf_acc_rotex5_grey";
this addPrimaryWeaponItem "rhs_acc_2dpZenit_ris";
this addPrimaryWeaponItem "rhsusf_acc_ACOG_RMR_3d";
this addPrimaryWeaponItem "rhssaf_30rnd_556x45_EPR_G36";
this addWeapon "rhsusf_weap_glock17g4";
this addHandgunItem "rhsusf_acc_omega9k";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "rhsusf_mag_17Rnd_9x19_JHP";
this addWeapon "rhs_pdu4";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhssaf_30rnd_556x45_EPR_G36";
for "_i" from 1 to 4 do {this addItemToVest "rhssaf_30rnd_556x45_EPR_G36";};
for "_i" from 1 to 2 do {this addItemToVest "rhssaf_30rnd_556x45_Tracers_G36";};
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_mag_17Rnd_9x19_JHP";};
this addItemToVest "rhs_grenade_mki_mag";
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_mkii_mag";};
this addItemToVest "rhs_grenade_anm8_mag";
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_mine_Mk2_tripwire_mag";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_mine_mk2_pressure_mag";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_ec400_sand_mag";};

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhs_1PN138";

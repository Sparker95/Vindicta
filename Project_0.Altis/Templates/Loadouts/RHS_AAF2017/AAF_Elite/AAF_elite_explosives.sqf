removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomVest = ["FGN_AAF_CIRAS_Engineer","FGN_AAF_CIRAS_Engineer_CamB"] call BIS_fnc_selectRandom;
this addVest _RandomVest;
_RandomHeadgear = ["FGN_AAF_PASGT_Type07","FGN_AAF_PASGT_Type07_ESS","FGN_AAF_PASGT_Type07_ESS_2"] call BIS_fnc_selectRandom;
this addHeadgear _RandomHeadgear;
_RandomGoggles = ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","","","",""] call BIS_fnc_selectRandom;
this addGoggles _RandomGoggles;
this forceAddUniform "FGN_AAF_M10_Type07_Summer";
this addBackpack "FGN_AAF_Bergen_Engineer_Type07";

this addWeapon "rhs_weap_m21s";
this addPrimaryWeaponItem "rhs_acc_2dpZenit";

this addItemToUniform "FirstAidKit";
this addItemToUniform "FGN_AAF_PatrolCap_Type07";
for "_i" from 1 to 7 do {this addItemToVest "rhsgref_30rnd_556x45_m21";};
this addItemToVest "rhs_grenade_anm8_mag";
for "_i" from 1 to 2 do {this addItemToVest "rhssaf_mag_brz_m88";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_ec200_sand_mag";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_ec400_sand_mag";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_ec75_sand_mag";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_charge_tnt_x2_mag";};

this linkItem "ItemWatch";
this linkItem "ItemRadio";

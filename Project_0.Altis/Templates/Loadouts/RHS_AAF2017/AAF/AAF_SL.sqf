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
this addBackpack "FGN_AAF_Fieldpack_Lizard";

this addWeapon "rhs_weap_akms_gp25";
this addPrimaryWeaponItem "rhs_acc_dtkakm";
this addWeapon "rhs_weap_tt33";
this addWeapon "rhssaf_zrak_rd7j";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhs_mag_762x25_8";
this addItemToUniform "rhs_30Rnd_762x39mm";
for "_i" from 1 to 4 do {this addItemToVest "rhs_30Rnd_762x39mm";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_762x25_8";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_mkii_mag";};
for "_i" from 1 to 6 do {this addItemToBackpack "rhs_VOG25";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_VG40OP_white";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_GRD40_White";};
this addItemToBackpack "rhs_GRD40_Red";
this addItemToBackpack "rhs_VG40OP_red";
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_grenade_mki_mag";};


this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

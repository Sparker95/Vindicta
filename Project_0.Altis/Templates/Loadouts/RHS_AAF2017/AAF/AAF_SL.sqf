
removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this forceAddUniform "FGN_AAF_M93_Lizard";
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToUniform "rhs_mag_9x18_8_57N181S";};
this addVest "FGN_AAF_M99Vest_Lizard_Rifleman_Radio";
for "_i" from 1 to 5 do {this addItemToVest "rhs_30Rnd_762x39mm";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_rdg2_white";};
this addBackpack "FGN_AAF_Fieldpack_Lizard";
for "_i" from 1 to 6 do {this addItemToBackpack "rhs_VOG25";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_VG40OP_white";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_GRD40_White";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_GRD40_Red";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_VG40OP_red";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_mag_nspd";};
_RandomHeadgear = ["FGN_AAF_PASGT_Lizard","FGN_AAF_PASGT_Lizard_ESS","FGN_AAF_PASGT_Lizard_ESS_2","rhsgref_helmet_pasgt_olive"] call BIS_fnc_selectRandom;  
  

this addHeadgear _RandomHeadgear;
_RandomGoggles = ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","","","",""] call BIS_fnc_selectRandom;  
  

this addGoggles _RandomGoggles;


this addWeapon "rhs_weap_akms_gp25";
this addPrimaryWeaponItem "rhs_acc_dtkakm";
this addWeapon "rhs_weap_makarov_pm";
this addWeapon "rhssaf_zrak_rd7j";

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

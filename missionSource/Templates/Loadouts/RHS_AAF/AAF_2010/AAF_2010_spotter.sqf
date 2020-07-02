removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomGoggles = selectRandom ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","",""];
this addGoggles _RandomGoggles;
_RandomHeadgear = selectRandom ["FGN_AAF_Boonie_Lizard","H_Bandanna_khk_hs","H_Shemag_olive_hs","H_ShemagOpen_tan"];
this addHeadgear _RandomHeadgear;
this forceaddUniform "FGN_FIA_M93_Rhodesian";
_RandomVest = selectRandom ["FGN_AAF_M99Vest_Lizard_Rifleman_Radio","FGN_AAF_M99Vest_Khaki_Rifleman_Radio"];
this addVest _RandomVest;

this addWeapon "rhs_weap_m70b3n";
this addPrimaryWeaponItem "rhs_acc_pbs1";
this addPrimaryWeaponItem "rhs_acc_2dpZenit";
_RandomSight = selectRandom ["rhs_acc_pkas", ""];
this addPrimaryWeaponItem _RandomSight;
this addPrimaryWeaponItem "rhs_30Rnd_762x39mm_U";
this addWeapon "rhs_weap_pb_6p9";
this addHandgunItem "rhs_acc_6p9_suppressor";
this addHandgunItem "rhs_mag_9x18_8_57N181S";
this addWeapon "Binocular";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "rhs_mag_9x18_8_57N181S";};
this addItemToUniform "rhs_grenade_anm8_mag";
this addItemToVest "rhs_grenade_mki_mag";
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_mkii_mag";};
for "_i" from 1 to 4 do {this addItemToVest "rhs_30Rnd_762x39mm_U";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
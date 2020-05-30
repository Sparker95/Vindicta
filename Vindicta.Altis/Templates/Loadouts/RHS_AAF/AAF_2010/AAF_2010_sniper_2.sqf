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
_RandomHeadgear = selectRandom ["FGN_AAF_Boonie_Lizard","H_Bandanna_khk_hs","H_Shemag_olive_hs","H_ShemagOpen_tan"];
this addHeadgear _RandomHeadgear;
this forceaddUniform "FGN_AAF_M93_Lizard";
_RandomVest = selectRandom ["FGN_AAF_M99Vest_Lizard_Radio","FGN_AAF_M99Vest_Khaki_Radio"];
this addVest _RandomVest;

this addWeapon "rhs_weap_m24sws";
this addPrimaryWeaponItem "rhsusf_acc_M8541";
this addPrimaryWeaponItem "rhsusf_5Rnd_762x51_m118_special_Mag";
this addPrimaryWeaponItem "rhsusf_acc_harris_swivel";
this addWeapon "rhs_weap_pb_6p9";
this addHandgunItem "rhs_acc_6p9_suppressor";
this addHandgunItem "rhs_mag_9x18_8_57N181S";
this addWeapon "Binocular";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToUniform "rhs_mag_9x18_8_57N181S";};
this addItemToVest "rhs_grenade_anm8_mag";
this addItemToVest "rhs_grenade_mkii_mag";
this addItemToVest "rhs_grenade_mki_mag";
for "_i" from 1 to 6 do {this addItemToVest "rhsusf_5Rnd_762x51_m118_special_Mag";};
for "_i" from 1 to 4 do {this addItemToVest "rhsusf_5Rnd_762x51_m62_Mag";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
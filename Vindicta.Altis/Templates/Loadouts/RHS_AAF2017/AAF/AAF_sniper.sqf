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
_RandomHeadgear = ["FGN_AAF_Boonie_Lizard","H_Bandanna_khk_hs","H_Bandanna_khk"] call BIS_fnc_selectRandom;
this addHeadgear _RandomHeadgear;
this forceAddUniform "FGN_AAF_M93_Lizard";
this addVest "FGN_AAF_M99Vest_Lizard_Radio";

this addWeapon "rhs_weap_m38_rail";
this addPrimaryWeaponItem "rhsusf_acc_LEUPOLDMK4";
this addPrimaryWeaponItem "rhsgref_5Rnd_762x54_m38";
this addWeapon "rhs_weap_pb_6p9";
this addHandgunItem "rhs_acc_6p9_suppressor";
this addHandgunItem "rhs_mag_9x18_8_57N181S";
this addWeapon "rhssaf_zrak_rd7j";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToUniform "rhs_mag_9x18_8_57N181S";};
for "_i" from 1 to 15 do {this addItemToVest "rhsgref_5Rnd_762x54_m38";};
this addItemToVest "rhs_grenade_anm8_mag";
this addItemToVest "rhs_grenade_mkii_mag";
this addItemToVest "rhs_grenade_mki_mag";

this linkItem "ItemWatch";
this linkItem "ItemRadio";

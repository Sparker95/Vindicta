removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["FGN_AAF_PASGT_Lizard","rhsgref_helmet_pasgt_olive","FGN_AAF_Boonie_Lizard"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","","",""];
this addGoggles _RandomGoggles;
this forceaddUniform "FGN_AAF_M93_Lizard";
_RandomVest = selectRandom ["FGN_AAF_M99Vest_Lizard","FGN_AAF_M99Vest_Khaki"];
this addVest _RandomVest;

this addWeapon "rhs_weap_l1a1_wood";
this addPrimaryWeaponItem "rhsgref_acc_falMuzzle_l1a1";
this addPrimaryWeaponItem "rhsgref_acc_l1a1_l2a2_3d";
this addPrimaryWeaponItem "rhs_mag_20Rnd_762x51_m80_fnfal";
this addWeapon "Binocular";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_20Rnd_762x51_m80_fnfal";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_20Rnd_762x51_m62_fnfal";};
this linkItem "ItemWatch";
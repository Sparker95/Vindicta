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
this addVest "FGN_AAF_M99Vest_Lizard";

this addWeapon "rhs_weap_l1a1_wood";
this addPrimaryWeaponItem "rhsgref_acc_falMuzzle_l1a1";
this addPrimaryWeaponItem "rhsgref_acc_l1a1_l2a2_3d";
this addPrimaryWeaponItem "rhs_mag_20Rnd_762x51_m80_fnfal";
this addWeapon "rhssaf_zrak_rd7j";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhs_mag_20Rnd_762x51_m80_fnfal";
for "_i" from 1 to 5 do {this addItemToVest "rhs_mag_20Rnd_762x51_m80_fnfal";};

this linkItem "ItemWatch";

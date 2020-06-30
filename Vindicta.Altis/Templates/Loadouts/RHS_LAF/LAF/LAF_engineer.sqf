removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["rhsgref_helmet_pasgt_olive","FGN_AAF_PASGT_M81","FGN_AAF_PASGT_M81_ESS", "FGN_AAF_PASGT_M81_ESS_2"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag_green","G_Bandanna_oli","",""];
this addGoggles _RandomGoggles;
this addVest "FGN_AAF_M99Vest_M81_Rifleman";
this forceaddUniform "rhsgref_uniform_olive";
this addBackpack "B_TacticalPack_blk";

this addWeapon "rhs_weap_M590_8RD";
this addPrimaryWeaponItem "rhsusf_8Rnd_00Buck";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "rhsusf_8Rnd_00Buck";};
for "_i" from 1 to 4 do {this addItemToVest "rhsusf_8Rnd_Slug";};
this addItemToBackpack "ToolKit";
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_mag_an_m14_th3";};
this linkItem "ItemWatch";
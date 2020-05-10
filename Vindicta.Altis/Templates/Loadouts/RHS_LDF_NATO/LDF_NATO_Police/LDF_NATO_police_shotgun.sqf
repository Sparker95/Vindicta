removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["H_Cap_blk","rhs_beret_milp","FGN_AAF_PASGT_Black"];
this addHeadgear _RandomHeadgear;
_RandomVest = selectRandom ["rhsusf_mbav", "FGN_AAF_M99Vest_Police_Rifleman", "FGN_AAF_M99Vest_Police_Rifleman_Radio"];
this addVest _RandomVest;
this forceaddUniform "rhs_uniform_g3_blk";

this addWeapon "rhs_weap_M590_8RD";
this addPrimaryWeaponItem "rhsusf_8Rnd_00Buck";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhssaf_mag_rshb_p98";
for "_i" from 1 to 2 do {this addItemToUniform "rhsusf_8Rnd_00Buck";};
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_8Rnd_Slug";};
this linkItem "ItemWatch";



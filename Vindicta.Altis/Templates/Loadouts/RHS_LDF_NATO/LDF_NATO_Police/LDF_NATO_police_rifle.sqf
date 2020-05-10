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

this addWeapon "rhs_weap_g36c";
this addPrimaryWeaponItem "rhsusf_acc_wmx_bk";
this addPrimaryWeaponItem "rhsusf_acc_T1_high";
this addPrimaryWeaponItem "rhsusf_acc_tdstubby_blk";
this addPrimaryWeaponItem "rhssaf_30rnd_556x45_EPR_G36";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhssaf_mag_rshb_p98";
for "_i" from 1 to 2 do {this addItemToVest "rhssaf_30rnd_556x45_EPR_G36";};
this linkItem "ItemWatch";


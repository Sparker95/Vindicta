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

this addWeapon "SMG_05_F";
this addPrimaryWeaponItem "rhsusf_acc_M952V";
this addPrimaryWeaponItem "rhsusf_acc_T1_low";
this addPrimaryWeaponItem "30Rnd_9x21_Mag_SMG_02";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToUniform "30Rnd_9x21_Mag_SMG_02";};
this addItemToUniform "rhssaf_mag_rshb_p98";
this linkItem "ItemWatch";






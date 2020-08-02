removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["H_Cap_blk","rhs_beret_milp"];
this addHeadgear _RandomHeadgear;
_RandomVest = selectRandom ["rhs_vest_pistol_holster", "rhs_vest_pistol_holster", "rhssaf_vest_md98_woodland"];
this addVest _RandomVest;
this forceaddUniform "rhsgref_uniform_olive";

this addWeapon "rhs_weap_aks74u";
this addPrimaryWeaponItem "rhs_acc_pgs64_74u";
this addPrimaryWeaponItem "rhs_30Rnd_545x39_7N6M_plum_AK";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhssaf_mag_rshb_p98";
for "_i" from 1 to 2 do {this addItemToVest "rhs_30Rnd_545x39_7N6M_plum_AK";};
this linkItem "ItemWatch";


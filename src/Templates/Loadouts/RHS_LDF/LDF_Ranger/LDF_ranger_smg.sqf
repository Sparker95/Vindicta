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

this addWeapon "rhs_weap_savz61";
this addPrimaryWeaponItem "rhsgref_20rnd_765x17_vz61";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "rhsgref_10rnd_765x17_vz61";};
this addItemToUniform "rhssaf_mag_rshb_p98";
for "_i" from 1 to 2 do {this addItemToVest "rhsgref_10rnd_765x17_vz61";};
for "_i" from 1 to 2 do {this addItemToVest "rhsgref_20rnd_765x17_vz61";};
this linkItem "ItemWatch";






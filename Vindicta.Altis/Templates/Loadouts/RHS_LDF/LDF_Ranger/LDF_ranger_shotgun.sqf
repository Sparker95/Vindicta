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

this addWeapon "sgun_HunterShotgun_01_F";
this addPrimaryWeaponItem "2Rnd_12Gauge_Pellets";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhssaf_mag_rshb_p98";
for "_i" from 1 to 3 do {this addItemToUniform "2Rnd_12Gauge_Pellets";};
for "_i" from 1 to 3 do {this addItemToVest "2Rnd_12Gauge_Slug";};
this linkItem "ItemWatch";



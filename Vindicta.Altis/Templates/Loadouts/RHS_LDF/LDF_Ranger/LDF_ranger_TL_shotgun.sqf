removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomVest = selectRandom ["rhs_vest_commander", "rhs_vest_commander", "rhssaf_vest_md98_woodland"];
this addVest _RandomVest;
this addHeadgear "rhs_beret_mvd";
this forceaddUniform "rhsgref_uniform_olive";

this addWeapon "sgun_HunterShotgun_01_sawedoff_F";
this addPrimaryWeaponItem "2Rnd_12Gauge_Pellets";
this addWeapon "rhs_weap_makarov_pm";
this addHandgunItem "rhs_mag_9x18_8_57N181S";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "rhs_mag_9x18_8_57N181S";};
this addItemToUniform "rhssaf_mag_rshb_p98";
for "_i" from 1 to 3 do {this addItemToVest "2Rnd_12Gauge_Pellets";};
for "_i" from 1 to 3 do {this addItemToVest "2Rnd_12Gauge_Slug";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";


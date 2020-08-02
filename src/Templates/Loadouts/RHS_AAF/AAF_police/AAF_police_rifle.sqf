removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["FGN_AAF_PatrolCap_Police","FGN_AAF_Beret_Police","H_Cap_police"];
this addHeadgear _RandomHeadgear;
this forceaddUniform "FGN_AAF_M93_Police";
this addVest "FGN_AAF_M99Vest_Police_Rifleman";

this addWeapon "rhs_weap_ak103_1";
this addPrimaryWeaponItem "rhs_acc_dtk";
this addPrimaryWeaponItem "rhs_30Rnd_762x39mm_polymer";

this addItemToUniform "FirstAidKit";
this addItemToVest "rhs_mag_m7a3_cs";
for "_i" from 1 to 2 do {this addItemToVest "rhs_30Rnd_762x39mm_polymer";};
for "_i" from 1 to 4 do {this addItemToVest "rhs_10Rnd_762x39mm";};
this linkItem "ItemWatch";


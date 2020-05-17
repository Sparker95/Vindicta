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
_RandomVest = selectRandom ["FGN_AAF_M99Vest_Police", "V_LegStrapBag_black_F"];
this addVest _RandomVest;
this forceaddUniform "FGN_AAF_M93_Police";

this addWeapon "rhs_weap_M590_5RD";
this addPrimaryWeaponItem "rhsusf_5Rnd_00Buck";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 5 do {this addItemToVest "rhsusf_5Rnd_00Buck";};
for "_i" from 1 to 5 do {this addItemToVest "rhsusf_5Rnd_Slug";};
this addItemToVest "rhs_mag_m7a3_cs";
this linkItem "ItemWatch";

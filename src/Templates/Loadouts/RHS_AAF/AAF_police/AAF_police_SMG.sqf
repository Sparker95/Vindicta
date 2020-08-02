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

this addWeapon "rhs_weap_pp2000";
this addPrimaryWeaponItem "rhs_mag_9x19mm_7n21_20";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "rhs_mag_9x19mm_7n21_20";};
this addItemToVest "rhs_mag_m7a3_cs";
this linkItem "ItemWatch";

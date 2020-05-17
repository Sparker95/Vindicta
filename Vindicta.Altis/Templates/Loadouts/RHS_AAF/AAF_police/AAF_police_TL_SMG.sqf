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
this addVest "FGN_AAF_M99Vest_Police_Radio";

this addWeapon "rhs_weap_pp2000";
this addPrimaryWeaponItem "rhs_acc_okp7_picatinny";
this addPrimaryWeaponItem "rhs_mag_9x19mm_7n21_20";
this addWeapon "rhs_weap_tt33";
this addHandgunItem "rhs_mag_762x25_8";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "rhs_mag_762x25_8";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_9x19mm_7n21_44";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_9x19mm_7n21_20";};
this addItemToVest "rhs_mag_m7a3_cs";
this addItemToVest "rhs_grenade_mkiiia1_mag";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
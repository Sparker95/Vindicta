removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = ["FGN_AAF_PatrolCap_Police","FGN_AAF_Beret_Police","H_Cap_police"] call BIS_fnc_selectRandom;
this addHeadgear _RandomHeadgear;
_RandomVest = ["FGN_AAF_M99Vest_Police_Radio", "rhs_vest_commander", "rhs_vest_pistol_holster"] call BIS_fnc_selectRandom;
this addVest _RandomVest;
this forceAddUniform "FGN_AAF_M93_Police";

this addWeapon "rhs_weap_pp2000";
this addPrimaryWeaponItem "rhsusf_acc_mrds";
this addWeapon "rhs_weap_makarov_pm";
this addHandgunItem "rhs_mag_9x18_8_57N181S";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToUniform "rhs_mag_9x18_8_57N181S";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_9x19mm_7n21_44";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_9x19mm_7n21_20";};
this addItemToVest "rhs_mag_m7a3_cs";
this addItemToVest "rhs_grenade_mkiiia1_mag";

this linkItem "ItemWatch";
this linkItem "ItemRadio";

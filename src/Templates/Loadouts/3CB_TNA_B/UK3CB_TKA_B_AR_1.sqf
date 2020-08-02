// ==== Remove items ====
removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;



[this, selectRandom gVanillaFaces, "male02per"] call BIS_fnc_setIdentity;

// ==== Uniform ====
this forceAddUniform "UK3CB_BAF_U_CombatUniform_MTP";
this addVest "UK3CB_TKA_B_V_GA_LITE_TAN";
this addBackpack "UK3CB_TKA_B_B_RIF";

// ==== BackPack Contents ====
for "_i" from 1 to 2 do {this addItemToBackpack "rhsusf_200Rnd_556x45_box";};
this addHeadgear "UK3CB_TKA_B_H_WDL";

// ==== Weapon ====
this addWeapon "rhs_weap_m249";
this addPrimaryWeaponItem "rhsusf_100Rnd_556x45_soft_pouch";
this addPrimaryWeaponItem "rhsusf_acc_saw_bipod";
this addWeapon "rhsusf_weap_m1911a1";
this addHandgunItem "rhsusf_mag_7x45acp_MHP";

// Miscellaneous items
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
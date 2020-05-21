removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomGoggles = selectRandom ["G_Aviator",""];
this addGoggles _RandomGoggles;
this forceaddUniform "rhsgref_uniform_og107";
this addVest "rhs_vest_pistol_holster";
this addHeadgear "H_Beret_blk";

this addWeapon "rhs_weap_m4_carryhandle";
this addPrimaryWeaponItem "rhsusf_acc_M952V";
this addPrimaryWeaponItem "rhs_mag_20Rnd_556x45_M196_Stanag_Tracer_Red";
this addWeapon "rhsusf_weap_m1911a1";
this addHandgunItem "rhsusf_mag_7x45acp_MHP";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_20Rnd_556x45_M193_Stanag";};
this addItemToVest "rhsusf_mag_7x45acp_MHP";
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
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
this forceAddUniform "malden_officer";
this addVest "malden_pcarrier";
this addHeadgear "malden_beret";

this addWeapon "SMG_02_F";
this addPrimaryWeaponItem "rhsusf_acc_M952V";
this addPrimaryWeaponItem "rhsusf_acc_mrds";
this addPrimaryWeaponItem "30Rnd_9x21_Mag_SMG_02";
this addWeapon "rhsusf_weap_m1911a1";
this addHandgunItem "rhsusf_mag_7x45acp_MHP";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "rhsusf_mag_7x45acp_MHP";};
for "_i" from 1 to 4 do {this addItemToVest "30Rnd_9x21_Mag_SMG_02";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
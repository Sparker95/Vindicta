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
this forceAddUniform "rhs_uniform_emr_patchless";
this addVest "rhs_6b23_digi_crewofficer";
this addHeadgear "rhs_beret_mvd";

this addWeapon "rhs_weap_ak74m_folded";
this addPrimaryWeaponItem "rhs_acc_dtk";
this addPrimaryWeaponItem "rhs_acc_2dpZenit";
this addPrimaryWeaponItem "rhs_30Rnd_545x39_7N10_AK";
this addWeapon "hgun_Pistol_heavy_02_F";
this addHandgunItem "6Rnd_45ACP_Cylinder";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToUniform "6Rnd_45ACP_Cylinder";};
for "_i" from 1 to 4 do {this addItemToVest "rhs_30Rnd_545x39_7N10_AK";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
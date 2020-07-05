removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["rhs_altyn_novisor_ess","rhs_altyn_novisor"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["G_Bandanna_oli","G_Balaclava_oli"];
this addGoggles _RandomGoggles;
this forceAddUniform "rhs_uniform_emr_patchless";
this addVest "rhs_6b23_digi_engineer";
this addBackpack "rhs_assault_umbts_engineer_empty";

this addWeapon "rhs_weap_ak105";
this addPrimaryWeaponItem "rhs_acc_ak5";
this addPrimaryWeaponItem "rhs_acc_2dpZenit";
this addPrimaryWeaponItem "rhs_30Rnd_545x39_7N10_AK";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "rhs_30Rnd_545x39_7N10_AK";};
this addItemToBackpack "ToolKit";
for "_i" from 1 to 2 do {this addItemToBackpack "rhssaf_mag_brz_m88";};
this linkItem "ItemWatch";
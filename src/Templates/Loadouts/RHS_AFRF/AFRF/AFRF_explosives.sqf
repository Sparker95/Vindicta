removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["rhs_altyn","rhs_altyn_visordown"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["G_Bandanna_oli","G_Balaclava_oli"];
this addGoggles _RandomGoggles;
this forceAddUniform "rhs_uniform_emr_patchless";
this addVest "rhs_6b23_digi_vydra_3m";
this addBackpack "rhs_assault_umbts_engineer_empty";

this addWeapon "rhs_weap_ak105";
this addPrimaryWeaponItem "rhs_acc_ak5";
this addPrimaryWeaponItem "rhs_acc_2dpZenit";
this addPrimaryWeaponItem "rhs_30Rnd_545x39_7N10_AK";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "rhs_30Rnd_545x39_7N10_AK";};
for "_i" from 1 to 2 do {this addItemToBackpack "DemoCharge_Remote_Mag";};
this addItemToBackpack "SatchelCharge_Remote_Mag";
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_charge_tnt_x2_mag";};
this linkItem "ItemWatch";
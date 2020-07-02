removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["rhs_6b27m_digi","rhs_6b27m_digi_bala","rhs_6b27m_digi_ess","rhs_6b27m_digi_ess_bala","rhs_6b27m_green","rhs_6b27m_green_bala","rhs_6b27m_green_ess","rhs_6b27m_green_ess_bala"];
this addHeadgear _RandomHeadgear;
_RandomVest = selectRandom ["rhs_6b23_digi_6sh92_radio","rhs_6b23_digi_6sh92_Spetsnaz"];
this addVest _RandomVest;
this forceaddUniform "rhs_uniform_emr_patchless";

this addWeapon "rhs_weap_ak74m";
this addPrimaryWeaponItem "rhs_acc_dtk";
this addPrimaryWeaponItem "rhs_acc_2dpZenit";
this addPrimaryWeaponItem "rhs_acc_1p63";
this addPrimaryWeaponItem "rhs_30Rnd_545x39_7N10_AK";
this addWeapon "Binocular";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhs_acc_perst1ik";
this addItemToUniform "Chemlight_red";
this addItemToUniform "rhs_mag_nspn_red";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_rgd5";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_30Rnd_545x39_7N10_AK";};
this addItemToVest "rhs_mag_rdg2_white";
for "_i" from 1 to 2 do {this addItemToVest "rhs_30Rnd_545x39_7N10_2mag_AK";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhs_1PN138";
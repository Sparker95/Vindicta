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
_RandomVest = selectRandom ["rhs_6b23_digi_6sh92_vog_headset","rhs_6b23_digi_6sh92_Vog_Radio_Spetsnaz"];
this addVest _RandomVest;
this forceaddUniform "rhs_uniform_emr_patchless";

this addWeapon "rhs_weap_ak74m_gp25";
this addPrimaryWeaponItem "rhs_acc_dtk";
this addPrimaryWeaponItem "rhs_acc_1p63";
this addPrimaryWeaponItem "rhs_30Rnd_545x39_7N10_AK";
this addPrimaryWeaponItem "rhs_VOG25";
this addWeapon "Binocular";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "rhs_mag_rgd5";};
this addItemToUniform "Chemlight_red";
this addItemToUniform "rhs_mag_nspn_red";
for "_i" from 1 to 4 do {this addItemToVest "rhs_30Rnd_545x39_7N10_AK";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_VG40MD";};
this addItemToVest "rhs_GRD40_Green";
this addItemToVest "rhs_GRD40_Red";
for "_i" from 1 to 6 do {this addItemToVest "rhs_VOG25";};
this addItemToVest "rhs_VG40OP_red";
for "_i" from 1 to 4 do {this addItemToVest "rhs_VG40OP_white";};
this addItemToVest "rhs_VG40OP_green";
for "_i" from 1 to 2 do {this addItemToVest "rhs_VOG25P";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhs_1PN138";
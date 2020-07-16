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
_RandomVest = selectRandom ["rhs_6b23_digi_6sh92_headset_mapcase","rhs_6b23_digi_6sh92_headset", "rhs_6b23_digi_6sh92_headset_spetsnaz"];
this addVest _RandomVest;
this forceaddUniform "rhs_uniform_emr_patchless";

this addWeapon "rhs_weap_ak74m";
this addPrimaryWeaponItem "rhs_acc_dtk";
this addPrimaryWeaponItem "rhs_acc_2dpZenit";
this addPrimaryWeaponItem "rhs_30Rnd_545x39_7N10_AK";
this addWeapon "rhs_weap_makarov_pm";
this addHandgunItem "rhs_mag_9x18_8_57N181S";
this addWeapon "Binocular";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhs_acc_perst1ik";
for "_i" from 1 to 2 do {this addItemToUniform "Chemlight_red";};
this addItemToUniform "rhs_mag_nspn_red";
for "_i" from 1 to 2 do {this addItemToUniform "rhs_mag_9x18_8_57N181S";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_rgd5";};
this addItemToVest "rhs_mag_rdg2_white";
this addItemToVest "rhs_mag_nspd";
this addItemToVest "rhs_mag_rdg2_black";
for "_i" from 1 to 2 do {this addItemToVest "rhs_30Rnd_545x39_7N10_AK";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_30Rnd_545x39_7N10_2mag_AK";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "rhs_1PN138";
removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["rhs_fieldcap_digi","rhs_6b27m_digi","rhs_6b27m_digi_bala","rhs_6b27m_digi_ess","rhs_6b27m_digi_ess_bala","rhs_6b27m_green","rhs_6b27m_green_bala","rhs_6b27m_green_ess","rhs_6b27m_green_ess_bala"];
this addHeadgear _RandomHeadgear;
_RandomVest = selectRandom ["rhs_6b23_digi_rifleman","rhs_6b23_digi_6sh92","rhs_6b23_digi_6sh92_spetsnaz2"];
this addVest _RandomVest;
this forceaddUniform "rhs_uniform_emr_patchless";
this addBackpack "rhs_rpg_empty";

this addWeapon "rhs_weap_ak74m";
this addPrimaryWeaponItem "rhs_acc_dtk";
this addPrimaryWeaponItem "rhs_acc_2dpZenit";
this addPrimaryWeaponItem "rhs_30Rnd_545x39_7N10_AK";
this addWeapon "rhs_weap_rpg7";
this addSecondaryWeaponItem "rhs_rpg7_PG7V_mag";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "rhs_30Rnd_545x39_7N10_AK";};
this addItemToVest "rhsgref_mag_rkg3em";
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_rpg7_PG7V_mag";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_rpg7_OG7V_mag";};
this linkItem "ItemWatch";
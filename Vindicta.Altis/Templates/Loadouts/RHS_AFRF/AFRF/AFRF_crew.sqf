removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["rhs_tsh4","rhs_tsh4_bala","rhs_tsh4_ess","rhs_tsh4_ess_bala"];
this addHeadgear _RandomHeadgear;
this addVest "rhs_vydra_3m";
this forceAddUniform "rhs_uniform_emr_patchless";

this addWeapon "rhs_weap_aks74u";
this addPrimaryWeaponItem "rhs_acc_pgs64_74u";
this addPrimaryWeaponItem "rhs_30Rnd_545x39_7N10_AK";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "rhs_30Rnd_545x39_7N10_AK";};
this addItemToVest "rhs_mag_rdg2_white";
this addHeadgear "rhs_tsh4";
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
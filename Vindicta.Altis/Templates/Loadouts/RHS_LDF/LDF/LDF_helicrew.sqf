removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this addHeadgear "rhs_zsh7a_mike_green_alt";
this forceaddUniform "rhssaf_uniform_m10_digital_summer";
this addVest "rhs_vydra_3m";

this addWeapon "rhs_weap_aks74u";
this addPrimaryWeaponItem "rhs_acc_pgs64_74u";

this addPrimaryWeaponItem "rhs_30Rnd_545x39_7N10_plum_AK";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "rhs_30Rnd_545x39_7N10_plum_AK";};
this addItemToVest "rhs_mag_rdg2_black";
this linkItem "ItemWatch";


removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["rhs_fieldcap_digi","rhs_Booniehat_digi","rhs_fieldcap_helm_digi"];
this addHeadgear _RandomHeadgear;
this addVest "rhs_6b23_digi_sniper";
this forceAddUniform "rhs_uniform_emr_patchless";

this addWeapon "rhs_weap_svds";
this addPrimaryWeaponItem "rhs_acc_pso1m2";
this addPrimaryWeaponItem "rhs_10Rnd_762x54mmR_7N1";

this addItemToUniform "FirstAidKit";
this addItemToVest "rhs_acc_1pn34";
for "_i" from 1 to 10 do {this addItemToVest "rhs_10Rnd_762x54mmR_7N1";};
this linkItem "ItemWatch";
removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomVest = selectRandom ["rhs_vest_commander", "rhs_vest_commander", "rhssaf_vest_md98_rifleman"];
this addVest _RandomVest;
this addHeadgear "rhs_beret_mvd";
this forceaddUniform "rhsgref_uniform_olive";

this addWeapon "rhs_weap_aks74u_folded";
this addPrimaryWeaponItem "rhs_acc_dtk2";
this addPrimaryWeaponItem "rhs_30Rnd_545x39_7N6M_plum_AK";
this addWeapon "rhs_weap_makarov_pm";
this addHandgunItem "rhs_mag_9x18_8_57N181S";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "rhs_mag_9x18_8_57N181S";};
this addItemToUniform "rhssaf_mag_rshb_p98";
this addItemToUniform "rhs_30Rnd_545x39_7N6M_plum_AK";
this addItemToVest "rhs_30Rnd_545x39_7N6M_plum_AK";
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";


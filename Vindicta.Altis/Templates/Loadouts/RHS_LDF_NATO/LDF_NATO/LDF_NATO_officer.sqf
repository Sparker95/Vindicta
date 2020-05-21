removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomGoggles = selectRandom ["G_Aviator",""];
this addGoggles _RandomGoggles;
this addHeadgear "H_Beret_EAF_01_F";
this forceaddUniform "rhsgref_uniform_para_ttsko_urban";
this addVest "rhssaf_vest_md99_digital";

this addWeapon "rhs_weap_g36c";
this addPrimaryWeaponItem "rhsusf_acc_eotech_552";
this addPrimaryWeaponItem "rhssaf_30rnd_556x45_EPR_G36";
this addWeapon "srifle_DMR_06_camo_F";
this addPrimaryWeaponItem "rhsusf_acc_su230a";
this addPrimaryWeaponItem "20Rnd_762x51_Mag";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "rhsusf_mag_17Rnd_9x19_FMJ";};
for "_i" from 1 to 5 do {this addItemToVest "rhssaf_30rnd_556x45_EPR_G36";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";


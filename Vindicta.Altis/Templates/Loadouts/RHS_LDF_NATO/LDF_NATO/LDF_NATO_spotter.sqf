removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["rhssaf_booniehat_digital","rhssaf_bandana_digital","rhsusf_Bowman","rhsusf_bowman_cap"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["G_Bandanna_oli","G_Balaclava_oli","","",""];
this addGoggles _RandomGoggles;
this forceaddUniform "rhsgref_uniform_para_ttsko_urban";
this addVest "rhssaf_vest_md12_digital";
this addBackpack "rhssaf_kitbag_digital";

this addWeapon "srifle_DMR_06_camo_F";
this addPrimaryWeaponItem "rhsusf_acc_su230a";
this addPrimaryWeaponItem "20Rnd_762x51_Mag";
this addWeapon "rhs_pdu4";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_rgd5";};
this addItemToVest "rhs_mag_rdg2_white";
this addItemToVest "rhs_mag_nspd";
for "_i" from 1 to 5 do {this addItemToVest "20Rnd_762x51_Mag";};
for "_i" from 1 to 2 do {this addItemToBackpack "APERSTripMine_Wire_Mag";};
for "_i" from 1 to 2 do {this addItemToBackpack "DemoCharge_Remote_Mag";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";




removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomUniform = selectRandom ["rhsgref_uniform_ERDL","rhsgref_uniform_og107","rhsgref_uniform_og107_erdl"];
this forceaddUniform _RandomUniform;
_RandomHeadgear = selectRandom ["H_Bandanna_khk_hs","H_Booniehat_khk_hs","H_Cap_oli_hs", "H_Booniehat_oli"];
this addHeadgear _RandomHeadgear;
_RandomVest = selectRandom ["rhsgref_chestrig","V_Chestrig_oli"];
this addVest _RandomVest;
this forceaddUniform "rhsgref_uniform_tigerstripe";

this addWeapon "rhs_weap_m24sws_wd";
this addPrimaryWeaponItem "rhsusf_acc_M8541_low_wd";
this addPrimaryWeaponItem "rhsusf_5Rnd_762x51_m118_special_Mag";
this addPrimaryWeaponItem "rhsusf_acc_harris_swivel";
this addWeapon "rhsusf_weap_m1911a1";
this addHandgunItem "rhsusf_mag_7x45acp_MHP";
this addWeapon "Binocular";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_mag_7x45acp_MHP";};
for "_i" from 1 to 5 do {this addItemToVest "rhsusf_5Rnd_762x51_m118_special_Mag";};
for "_i" from 1 to 5 do {this addItemToVest "rhsusf_5Rnd_762x51_m62_Mag";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
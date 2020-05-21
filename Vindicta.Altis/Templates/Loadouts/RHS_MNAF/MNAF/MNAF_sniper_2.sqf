removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this forceAddUniform "malden_ghillie";
this addVest "V_Chestrig_khk";

this addWeapon "rhs_weap_m40a5";
this addPrimaryWeaponItem "rhsusf_acc_anpeq15side_bk";
this addPrimaryWeaponItem "rhsusf_acc_premier";
this addPrimaryWeaponItem "rhsusf_5Rnd_762x51_AICS_m118_special_Mag";
this addPrimaryWeaponItem "rhsusf_acc_harris_swivel";
this addWeapon "rhsusf_weap_m1911a1";
this addHandgunItem "rhsusf_mag_7x45acp_MHP";
this addWeapon "Binocular";

this addItemToUniform "FirstAidKit";
this addItemToVest "rhsusf_acc_premier_anpvs27";
this addItemToVest "rhs_grenade_mkii_mag";
this addItemToVest "rhs_grenade_mki_mag";
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_mag_7x45acp_MHP";};
for "_i" from 1 to 4 do {this addItemToVest "rhsusf_10Rnd_762x51_m118_special_Mag";};
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_10Rnd_762x51_m62_Mag";};
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_10Rnd_762x51_m993_Mag";};
for "_i" from 1 to 6 do {this addItemToVest "rhsusf_5Rnd_762x51_AICS_m118_special_Mag";};
for "_i" from 1 to 4 do {this addItemToVest "rhsusf_5Rnd_762x51_AICS_m993_Mag";};
for "_i" from 1 to 6 do {this addItemToVest "rhsusf_5Rnd_762x51_AICS_m62_Mag";};
this addItemToVest "rhs_mag_an_m8hc";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "NVGoggles_OPFOR";
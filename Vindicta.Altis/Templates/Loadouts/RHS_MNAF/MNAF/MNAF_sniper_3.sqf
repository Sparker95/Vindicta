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

this addWeapon "rhs_weap_XM2010_wd";
this addPrimaryWeaponItem "rhsusf_acc_M2010S_wd";
this addPrimaryWeaponItem "rhsusf_acc_anpeq15side_bk";
this addPrimaryWeaponItem "rhsusf_acc_premier";
this addPrimaryWeaponItem "rhsusf_5Rnd_300winmag_xm2010";
this addPrimaryWeaponItem "rhsusf_acc_harris_bipod";
this addWeapon "rhsusf_weap_m1911a1";
this addHandgunItem "rhsusf_mag_7x45acp_MHP";
this addWeapon "Binocular";

this addItemToUniform "FirstAidKit";
this addItemToVest "rhsusf_acc_premier_anpvs27";
this addItemToVest "rhs_grenade_mkii_mag";
this addItemToVest "rhs_grenade_mki_mag";
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_mag_7x45acp_MHP";};
for "_i" from 1 to 20 do {this addItemToVest "rhsusf_5Rnd_300winmag_xm2010";};
this addItemToVest "rhs_mag_an_m8hc";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "NVGoggles_OPFOR";
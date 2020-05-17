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
this addBackpack "B_AssaultPack_cbr";

this addWeapon "rhs_weap_m16a4_imod_M203";
this addPrimaryWeaponItem "rhsusf_acc_SF3P556";
this addPrimaryWeaponItem "rhsusf_acc_anpeq15side_bk";
this addPrimaryWeaponItem "rhsusf_acc_ACOG_RMR";
this addPrimaryWeaponItem "rhs_mag_30Rnd_556x45_Mk318_Stanag";
this addWeapon "rhsusf_bino_lrf_Vector21";

this addItemToUniform "FirstAidKit";
this addItemToVest "rhs_grenade_mki_mag";
this addItemToVest "rhs_grenade_mkii_mag";
for "_i" from 1 to 8 do {this addItemToVest "rhs_mag_30Rnd_556x45_Mk318_Stanag";};
this addItemToVest "rhs_mag_an_m8hc";
this addItemToVest "rhs_mag_m18_green";
this addItemToVest "rhs_mag_m18_red";
for "_i" from 1 to 2 do {this addItemToBackpack "DemoCharge_Remote_Mag";};
for "_i" from 1 to 10 do {this addItemToBackpack "rhs_mag_M433_HEDP";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_mag_M397_HET";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "NVGoggles_OPFOR";
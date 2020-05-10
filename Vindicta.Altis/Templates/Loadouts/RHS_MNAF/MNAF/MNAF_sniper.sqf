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

this addWeapon "srifle_LRR_F";
this addPrimaryWeaponItem "optic_LRPS";
this addPrimaryWeaponItem "7Rnd_408_Mag";
this addWeapon "rhsusf_weap_m1911a1";
this addHandgunItem "rhsusf_mag_7x45acp_MHP";
this addWeapon "Binocular";

this addItemToUniform "FirstAidKit";
this addItemToVest "rhs_grenade_mkii_mag";
this addItemToVest "rhs_grenade_mki_mag";
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_mag_7x45acp_MHP";};
for "_i" from 1 to 6 do {this addItemToVest "7Rnd_408_Mag";};
this addItemToVest "rhs_mag_an_m8hc";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "NVGoggles_OPFOR";
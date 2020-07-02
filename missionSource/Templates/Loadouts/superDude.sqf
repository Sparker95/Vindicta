comment "Exported from Arsenal by Sparker";

comment "[!] UNIT MUST BE LOCAL [!]";
if (!local this) exitWith {};

comment "Remove existing items";
removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

comment "Add containers";
this forceAddUniform "U_C_Driver_4";
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "10Rnd_9x21_Mag";};
this addVest "V_PlateCarrierSpec_blk";
this addItemToVest "SmokeShell";
this addItemToVest "SmokeShellGreen";
this addItemToVest "Chemlight_green";
for "_i" from 1 to 2 do {this addItemToVest "200Rnd_556x45_Box_Tracer_Red_F";};
this addBackpack "B_ViperLightHarness_blk_F";
for "_i" from 1 to 4 do {this addItemToBackpack "MRAWS_HE_F";};
for "_i" from 1 to 6 do {this addItemToBackpack "HandGrenade";};
this addHeadgear "H_Bandanna_surfer_blk";
this addGoggles "G_Bandanna_blk";

comment "Add weapons";
this addWeapon "LMG_03_F";
this addPrimaryWeaponItem "muzzle_snds_M";
this addPrimaryWeaponItem "acc_pointer_IR";
this addPrimaryWeaponItem "optic_LRPS";
this addWeapon "launch_MRAWS_green_F";
this addWeapon "hgun_Pistol_01_F";

comment "Add items";
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "ItemGPS";

comment "Set identity";
[this,"WhiteHead_11","male03eng"] call BIS_fnc_setIdentity;

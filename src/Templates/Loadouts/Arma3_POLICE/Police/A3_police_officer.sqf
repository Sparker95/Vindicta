
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

comment "Add weapons";
this addWeapon "SMG_01_F";
this addPrimaryWeaponItem "optic_ACO_grn_smg";
this addPrimaryWeaponItem "30Rnd_45ACP_Mag_SMG_01";
this addWeapon "hgun_Pistol_heavy_02_F";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "6Rnd_45ACP_Cylinder";

comment "Add containers";
this forceAddUniform "U_B_GEN_Commander_F";
this addVest "V_TacVest_blk_POLICE";

comment "Add items to containers";
for "_i" from 1 to 2 do {this addItemToUniform "FirstAidKit";};
for "_i" from 1 to 2 do {this addItemToVest "6Rnd_45ACP_Cylinder";};
this addItemToUniform "ACE_Chemlight_HiBlue";
for "_i" from 1 to 2 do {this addItemToVest "Chemlight_blue";};
for "_i" from 1 to 3 do {this addItemToVest "30Rnd_45ACP_Mag_SMG_01";};
this addHeadgear "H_Beret_gen_F";

comment "Add items";
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

comment "Set identity";
[this,"Default","male02gre"] call BIS_fnc_setIdentity;

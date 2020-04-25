removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this addHeadgear "H_HelmetSpecB_blk";
_RandomGoggles = selectRandom ["G_Balaclava_TI_tna_F", "G_Balaclava_TI_G_tna_F"];
this addGoggles _RandomGoggles;
_RandomUniform = selectRandom ["U_B_CTRG_Soldier_F", "U_B_CTRG_Soldier_3_F", "U_B_CTRG_Soldier_2_F"];
this forceAddUniform _RandomUniform;
this addVest "V_CarrierRigKBT_01_light_EAF_F";
this addBackpack "B_AssaultPack_eaf_F";

this addWeapon "arifle_MXC_Black_F";
this addPrimaryWeaponItem "muzzle_snds_65_TI_blk_F";
this addPrimaryWeaponItem "acc_pointer_IR";
this addPrimaryWeaponItem "optic_Holosight_blk_F";
this addPrimaryWeaponItem "30Rnd_65x39_caseless_black_mag";
this addWeapon "hgun_Pistol_heavy_01_green_F";
this addHandgunItem "muzzle_snds_acp";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "optic_MRD_black";
this addHandgunItem "11Rnd_45ACP_Mag";
this addWeapon "launch_MRAWS_green_F";
this addSecondaryWeaponItem "acc_pointer_IR";
this addSecondaryWeaponItem "MRAWS_HEAT_F";


for "_i" from 1 to 2 do {this addItemToUniform "FirstAidKit";};
for "_i" from 1 to 5 do {this addItemToVest "30Rnd_65x39_caseless_black_mag";};
for "_i" from 1 to 3 do {this addItemToVest "11Rnd_45ACP_Mag";};
for "_i" from 1 to 2 do {this addItemToVest "SmokeShell";};
for "_i" from 1 to 2 do {this addItemToVest "HandGrenade";};
for "_i" from 1 to 2 do {this addItemToVest "MiniGrenade";};
for "_i" from 1 to 2 do {this addItemToUniform "Chemlight_blue";};
for "_i" from 1 to 2 do {this addItemToBackpack "MRAWS_HE_F";};
for "_i" from 1 to 2 do {this addItemToBackpack "MRAWS_HEAT_F";};

this linkItem "ItemMap";
this linkItem "ItemGPS";
this linkItem "ItemRadio";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "NVGogglesB_blk_F";

[this,"EAF_5thRegiment"] call BIS_fnc_setUnitInsignia;
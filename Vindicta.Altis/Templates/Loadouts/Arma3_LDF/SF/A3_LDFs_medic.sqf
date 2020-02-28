removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["H_HelmetSpecB_blk"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["G_Balaclava_TI_tna_F", "G_Balaclava_TI_G_tna_F"];
this addGoggles _RandomGoggles;
this forceAddUniform "U_B_CTRG_Soldier_F";
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

[["arifle_MXC_Black_F","muzzle_snds_65_TI_blk_F","acc_pointer_IR","optic_Holosight_blk_F",["30Rnd_65x39_caseless_black_mag",30],[],""],[],["hgun_Pistol_heavy_01_green_F","muzzle_snds_acp","acc_flashlight_pistol","optic_MRD_black",["11Rnd_45ACP_Mag",11],[],""],["U_B_CTRG_Soldier_F",[["FirstAidKit",1],["SmokeShell",1,1],["Chemlight_blue",1,1]]],["V_CarrierRigKBT_01_light_EAF_F",[]],["B_AssaultPack_eaf_F",[["Medikit",1]]],"H_HelmetSpecB_blk","G_Balaclava_TI_tna_F",[],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch","NVGogglesB_blk_F"]]


for "_i" from 1 to 2 do {this addItemToUniform "FirstAidKit";};
for "_i" from 3 to 6 do {this addItemToVest "30Rnd_65x39_caseless_black_mag";};
for "_i" from 2 to 3 do {this addItemToVest "11Rnd_45ACP_Mag";};
for "_i" from 1 to 2 do {this addItemToVest "SmokeShell";};
for "_i" from 1 to 2 do {this addItemToVest "HandGrenade";};
for "_i" from 1 to 2 do {this addItemToVest "MiniGrenade";};
for "_i" from 1 to 2 do {this addItemToUniform "Chemlight_blue";};
for "_i" from 2 to 4 do {this addItemToBackpack "FirstAidKit";};
this addItemToBackpack "Medikit";

this linkItem "ItemMap";
this linkItem "ItemGPS";
this linkItem "ItemRadio";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "NVGogglesB_blk_F";

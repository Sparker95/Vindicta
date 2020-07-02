removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this addGoggles "G_Balaclava_oli";
this forceAddUniform "U_B_FullGhillie_lsh";
this addVest "V_Chestrig_rgr";

this addWeapon "arifle_MSBS65_F";
this addPrimaryWeaponItem "ACE_muzzle_mzls_H";
this addPrimaryWeaponItem "acc_pointer_IR";
this addPrimaryWeaponItem "optic_MRCO";
this addPrimaryWeaponItem "30Rnd_65x39_caseless_msbs_mag";
this addWeapon "hgun_Pistol_heavy_01_green_F";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "optic_MRD_black";
this addHandgunItem "11Rnd_45ACP_Mag";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 7 do {this addItemToVest "30Rnd_65x39_caseless_msbs_mag";};
for "_i" from 1 to 3 do {this addItemToVest "11Rnd_45ACP_Mag";};
for "_i" from 1 to 2 do {this addItemToVest "SmokeShell";};
for "_i" from 1 to 2 do {this addItemToUniform "Chemlight_blue";};

this linkItem "ItemMap";
this linkItem "ItemGPS";
this linkItem "ItemRadio";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "NVGoggles_INDEP";
this linkItem "Rangefinder";

[["arifle_MSBS65_F","ACE_muzzle_mzls_H","acc_pointer_IR","optic_MRCO",["30Rnd_65x39_caseless_msbs_mag",30],[],""],[],["hgun_Pistol_heavy_01_green_F","","acc_flashlight_pistol","optic_MRD_black",["11Rnd_45ACP_Mag",11],[],""],["U_B_GhillieSuit",[["FirstAidKit",1],["ACE_Clacker",1],["SmokeShell",1,1]]],["V_Chestrig_rgr",[["ClaymoreDirectionalMine_Remote_Mag",1,1],["APERSTripMine_Wire_Mag",1,1],["SmokeShellGreen",1,1],["SmokeShellBlue",1,1],["SmokeShellOrange",1,1],["Chemlight_green",2,1]]],[],"","G_Balaclava_oli",["Rangefinder","","","",[],[],""],["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch","NVGoggles_INDEP"]]
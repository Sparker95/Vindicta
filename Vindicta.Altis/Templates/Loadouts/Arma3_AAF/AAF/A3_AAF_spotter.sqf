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

this addWeapon "SMG_03_TR_khaki";
this addPrimaryWeaponItem "acc_pointer_IR";
this addPrimaryWeaponItem "optic_Holosight_blk_F";
this addPrimaryWeaponItem "50Rnd_570x28_SMG_03";
this addWeapon "hgun_ACPC2_F";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "9Rnd_45ACP_Mag";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 5 do {this addItemToVest "50Rnd_570x28_SMG_03";};
for "_i" from 1 to 3 do {this addItemToVest "9Rnd_45ACP_Mag";};
for "_i" from 1 to 2 do {this addItemToVest "SmokeShell";};
for "_i" from 1 to 2 do {this addItemToUniform "Chemlight_blue";};

this linkItem "ItemMap";
this linkItem "ItemGPS";
this linkItem "ItemRadio";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "NVGoggles_INDEP";
this linkItem "Rangefinder";

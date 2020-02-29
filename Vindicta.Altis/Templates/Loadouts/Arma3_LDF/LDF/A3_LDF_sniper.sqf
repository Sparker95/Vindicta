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

this addWeapon "srifle_LRR_F";
this addPrimaryWeaponItem "optic_LRPS";
this addPrimaryWeaponItem "7Rnd_408_Mag";
this addWeapon "hgun_Pistol_heavy_01_green_F";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "optic_MRD_black";
this addHandgunItem "11Rnd_45ACP_Mag";


this addItemToUniform "FirstAidKit";
for "_i" from 1 to 5 do {this addItemToVest "7Rnd_408_Mag";};
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

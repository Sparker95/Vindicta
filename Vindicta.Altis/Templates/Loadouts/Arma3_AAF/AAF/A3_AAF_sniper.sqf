removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this addGoggles "G_Balaclava_oli";
this forceAddUniform "U_I_FullGhillie_sard";
this addVest "V_Chestrig_rgr";

this addWeapon "srifle_GM6_LRPS_F";
this addPrimaryWeaponItem "optic_LRPS";
this addPrimaryWeaponItem "5Rnd_127x108_Mag";
this addWeapon "hgun_ACPC2_F";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "9Rnd_45ACP_Mag";


this addItemToUniform "FirstAidKit";
for "_i" from 1 to 7 do {this addItemToVest "7Rnd_408_Mag";};
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

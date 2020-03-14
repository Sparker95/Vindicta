removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this addHeadgear "H_HelmetHBK_ear_F";
this forceAddUniform "U_I_E_Uniform_01_shortsleeve_F";
this addVest "V_CarrierRigKBT_01_light_EAF_F";
this addBackpack "B_AssaultPack_eaf_F";

this addWeapon "MMG_02_black_F";
this addPrimaryWeaponItem "ACE_muzzle_mzls_338";
this addPrimaryWeaponItem "acc_flashlight";
this addPrimaryWeaponItem "optic_Hamr";
this addPrimaryWeaponItem "130Rnd_338_Mag";
this addPrimaryWeaponItem "bipod_01_F_blk";


this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToBackpack "130Rnd_338_Mag";};
for "_i" from 1 to 2 do {this addItemToVest "SmokeShell";};
for "_i" from 1 to 2 do {this addItemToVest "HandGrenade";};
for "_i" from 1 to 2 do {this addItemToVest "MiniGrenade";};
for "_i" from 1 to 2 do {this addItemToUniform "Chemlight_blue";};

this linkItem "ItemMap";
this linkItem "ItemGPS";
this linkItem "ItemRadio";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "NVGoggles_INDEP";

removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this addHeadgear "H_HelmetIA_camo";
this forceAddUniform "U_I_CombatUniform_shortsleeve";
this addVest "V_PlateCarrierIA2_dgtl";
this addBackpack "B_AssaultPack_rgr";

this addWeapon "MMG_01_tan_F";
this addPrimaryWeaponItem "ACE_muzzle_mzls_93mmg";
this addPrimaryWeaponItem "acc_flashlight";
this addPrimaryWeaponItem "optic_ERCO_khk_F";
this addPrimaryWeaponItem "150Rnd_93x64_Mag";
this addPrimaryWeaponItem "bipod_03_F_blk";


this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToBackpack "150Rnd_93x64_Mag";};
for "_i" from 1 to 2 do {this addItemToVest "SmokeShell";};
for "_i" from 1 to 2 do {this addItemToVest "HandGrenade";};
for "_i" from 1 to 2 do {this addItemToVest "MiniGrenade";};
for "_i" from 1 to 2 do {this addItemToUniform "Chemlight_green";};

this linkItem "ItemMap";
this linkItem "ItemGPS";
this linkItem "ItemRadio";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "NVGoggles_INDEP";

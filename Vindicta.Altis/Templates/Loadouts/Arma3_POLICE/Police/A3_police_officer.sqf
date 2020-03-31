comment "Exported from Arsenal by MatrikSky";

removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

/*Helmet*/
this addHeadgear "H_Beret_gen_F";
/*Uniform*/
this forceAddUniform "U_B_GEN_Commander_F";
/*Vest*/
this addVest "V_TacVest_gen_F";
/*Backpack*/

/*Weapon*/
this addWeapon "SMG_05_F";
this addWeapon "hgun_Pistol_heavy_02_F";
/*WeaponItem*/
this addPrimaryWeaponItem "acc_flashlight";
_RandomPrimaryWeaponItem = selectRandom ["optic_Yorris", "optic_Holosight_smg_blk_F", ""];
this addPrimaryWeaponItem _RandomPrimaryWeaponItem;
this addPrimaryWeaponItem "30Rnd_9x21_Mag_SMG_02";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "6Rnd_45ACP_Cylinder";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 5 do {this addItemToUniform "6Rnd_45ACP_Cylinder";};
this addItemToUniform "ACE_M84";
for "_i" from 1 to 3 do {this addItemToVest "30Rnd_9x21_Mag_SMG_02";};
for "_i" from 1 to 2 do {this addItemToVest "ACE_Chemlight_HiBlue";};
for "_i" from 1 to 4 do {this addItemToVest "Chemlight_blue";};

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

[this,"Default","male04gre"] call BIS_fnc_setIdentity;

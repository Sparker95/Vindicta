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
this addVest "V_TacVest_blk_POLICE";
/*Backpack*/

/*Weapon*/
this addWeapon "arifle_MSBS65_black_F";
this addWeapon "hgun_Pistol_heavy_02_F";
/*WeaponItem*/
this addPrimaryWeaponItem "acc_flashlight";
_RandomPrimaryWeaponItem = selectRandom ["optic_ACO_grn", "optic_Holosight", "optic_Holosight_blk_F"];
this addPrimaryWeaponItem _RandomPrimaryWeaponItem;
this addPrimaryWeaponItem "30Rnd_65x39_caseless_msbs_mag";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "6Rnd_45ACP_Cylinder";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "6Rnd_45ACP_Cylinder";};
this addItemToUniform "ACE_M84";
for "_i" from 1 to 2 do {this addItemToVest "30Rnd_65x39_caseless_msbs_mag";};
this addItemToUniform "ACE_Chemlight_HiBlue";
for "_i" from 1 to 2 do {this addItemToUniform "Chemlight_blue";};

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

[this,"Default","male04gre"] call BIS_fnc_setIdentity;

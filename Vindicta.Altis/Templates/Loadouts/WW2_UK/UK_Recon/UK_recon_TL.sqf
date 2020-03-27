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
_RandomHeadgear = selectRandom ["H_LIB_UK_Beret_Commando"];
this addHeadgear _RandomHeadgear;
/*Gogles*/
_RandomGoggles = selectRandom ["G_LIB_Binoculars", ""];
this addGoggles _RandomGoggles;
/*Uniform*/
this forceAddUniform "fow_u_uk_bd40_commando_01_private";
/*Vest*/
this addVest "V_LIB_UK_P37_Holster_Blanco";
/*Backpack*/
_RandomBackpack = selectRandom ["B_LIB_UK_HSack_Blanco", "B_LIB_UK_HSack_Blanco_Cape", "B_LIB_UK_HSack_Blanco_Tea", "fow_b_uk_p37_blanco", ""];
this addBackpack _RandomBackpack;

/*Weapon*/
this addWeapon "LIB_M1A1_Thompson";
this addWeapon "fow_w_welrod_mkii";
/*WeaponItem*/
this addPrimaryWeaponItem "LIB_30Rnd_45ACP";
this addHandgunItem "fow_8rnd_765x17";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "LIB_30Rnd_45ACP";};
for "_i" from 1 to 2 do {this addItemToVest "fow_8rnd_765x17";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_MillsBomb";};
this addItemToVest "LIB_US_M18";
this addItemToVest "LIB_No77";
this addItemToVest "fow_e_mk2";

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "LIB_Binocular_UK";

[this,"Default","male05engb"] call BIS_fnc_setIdentity;

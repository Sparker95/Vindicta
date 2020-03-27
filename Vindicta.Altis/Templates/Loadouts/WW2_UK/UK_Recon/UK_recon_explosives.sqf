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
_RandomHeadgear = selectRandom ["H_LIB_UK_Beret_Commando", "H_LIB_UK_Helmet_Mk2_Camo", "H_LIB_UK_Helmet_Mk2_FAK_Camo", "H_LIB_UK_Helmet_Mk3_Camo"];
this addHeadgear _RandomHeadgear;
/*Uniform*/
this forceAddUniform "fow_u_uk_bd40_commando_01_private";
/*Vest*/
this addVest "V_LIB_UK_P37_Sten";
/*Backpack*/
_RandomBackpack = selectRandom ["fow_b_uk_bergenpack","B_LIB_UK_HSack_Blanco", "B_LIB_UK_HSack_Blanco_Cape", "B_LIB_UK_HSack_Blanco_Tea", "fow_b_uk_p37_blanco"];
this addBackpack _RandomBackpack;

/*Weapon*/
this addWeapon "LIB_Sten_Mk5";
/*WeaponItem*/
this addPrimaryWeaponItem "lib_32rnd_9x19_sten";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "lib_32rnd_9x19_sten";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_MillsBomb";};
this addItemToVest "LIB_US_M18";
this addItemToVest "LIB_No77";
this addItemToVest "fow_e_mk2";
this addItemToBackpack "LIB_US_M1A1_ATMINE_mag";
this addItemToBackpack "LIB_US_TNT_4pound_mag";
this addItemToBackpack "LIB_Ladung_Big_MINE_mag";
this addItemToBackpack "LIB_Ladung_Small_MINE_mag";
this addItemToBackpack "LIB_US_M3_MINE_mag";

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";

[this,"Default","male03engb"] call BIS_fnc_setIdentity;

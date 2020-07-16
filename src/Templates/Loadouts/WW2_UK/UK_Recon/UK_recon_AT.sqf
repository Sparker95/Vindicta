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
_RandomVest = selectRandom ["V_LIB_UK_P37_Rifleman_Blanco", "V_LIB_UK_P37_Gasmask_Blanco"];
this addVest _RandomVest;
/*Backpack*/
this addBackpack "fow_b_uk_piat";

/*Weapon*/
this addWeapon "LIB_M3_GreaseGun";
this addWeapon "LIB_PIAT";
/*WeaponItem*/
this addPrimaryWeaponItem "LIB_30Rnd_45ACP";
this addSecondaryWeaponItem "LIB_1Rnd_89m_PIAT";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToVest "LIB_30Rnd_45ACP";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_MillsBomb";};
for "_i" from 1 to 3 do {this addItemToBackpack "LIB_1Rnd_89m_PIAT";};
this addItemToVest "LIB_US_M18";
this addItemToVest "fow_e_mk2";

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";

[this,"Default","male04engb"] call BIS_fnc_setIdentity;

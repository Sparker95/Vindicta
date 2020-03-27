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
_RandomHeadgear = selectRandom ["H_LIB_UK_Helmet_Mk2", "H_LIB_UK_Helmet_Mk2_Bowed", "H_LIB_UK_Helmet_Mk2_FAK", "H_LIB_UK_Helmet_Mk2_Net", "H_LIB_UK_Helmet_Mk2", "H_LIB_UK_Helmet_Mk2_Bowed", "H_LIB_UK_Helmet_Mk2_FAK", "H_LIB_UK_Helmet_Mk2_Net", "H_LIB_UK_Helmet_Mk2", "H_LIB_UK_Helmet_Mk2_Bowed", "H_LIB_UK_Helmet_Mk2_FAK", "H_LIB_UK_Helmet_Mk2_Net", "H_LIB_UK_Helmet_Mk2", "H_LIB_UK_Helmet_Mk2_Bowed", "H_LIB_UK_Helmet_Mk2_FAK", "H_LIB_UK_Helmet_Mk2_Net", "H_LIB_UK_Helmet_Mk3", "H_LIB_UK_Helmet_Mk3_Net", "fow_h_uk_jungle_hat_01", "fow_h_uk_jungle_hat_02", "fow_h_uk_jungle_hat_03", "fow_h_uk_woolen_hat", "fow_h_uk_woolen_hat02"];
this addHeadgear _RandomHeadgear;
/*Uniform*/
this forceAddUniform "U_LIB_UK_P37";
/*Vest*/
this addVest "V_LIB_UK_P37_Sten";
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

[this,"Default","male01engb"] call BIS_fnc_setIdentity;

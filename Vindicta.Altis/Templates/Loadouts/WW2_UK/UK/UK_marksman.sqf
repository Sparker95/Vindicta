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
/*Gogles*/
this addGoggles "G_LIB_Binoculars";
/*Uniform*/
this forceAddUniform "U_LIB_UK_P37";
/*Vest*/
_RandomVest = selectRandom ["V_LIB_UK_P37_Rifleman", "V_LIB_UK_P37_Gasmask"];
this addVest _RandomVest;
/*Backpack*/
_RandomBackpack = selectRandom ["B_LIB_UK_HSack", "B_LIB_UK_HSack_Cape", "B_LIB_UK_HSack_Tea", "fow_b_uk_p37", ""];
this addBackpack _RandomBackpack;

/*Weapon*/
this addWeapon "LIB_LeeEnfield_No4_Scoped";
this addWeapon "LIB_Webley_mk6";
/*WeaponItem*/
this addPrimaryWeaponItem "LIB_10Rnd_770x56";
this addHandgunItem "LIB_6Rnd_455";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "LIB_10Rnd_770x56";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_6Rnd_455";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_MillsBomb";};
this addItemToVest "LIB_US_M18";
this addItemToVest "fow_e_mk2";

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "LIB_Binocular_UK";

[this,"Default","male04engb"] call BIS_fnc_setIdentity;

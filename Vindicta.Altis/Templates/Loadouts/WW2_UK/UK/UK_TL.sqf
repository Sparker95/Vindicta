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
_RandomGoggles = selectRandom ["G_LIB_Binoculars", ""];
this addGoggles _RandomGoggles;
/*Uniform*/
_RandomUniform = selectRandom ["U_LIB_UK_P37_Corporal", "U_LIB_UK_P37_LanceCorporal"];
this forceAddUniform _RandomUniform;
/*Vest*/
this addVest "V_LIB_UK_P37_Holster";
/*Backpack*/
_RandomBackpack = selectRandom ["B_LIB_UK_HSack", "B_LIB_UK_HSack_Cape", "B_LIB_UK_HSack_Tea", "fow_b_uk_p37", "fow_b_uk_p37_radio", "B_LIB_US_Radio_ACRE2", ""];
this addBackpack _RandomBackpack;

/*Weapon*/
_RandomWeapon = selectRandom ["LIB_LeeEnfield_No4", "LIB_LeeEnfield_No1"];
this addWeapon _RandomWeapon;
this addWeapon "LIB_Webley_Flare";
/*WeaponItem*/
this addPrimaryWeaponItem "LIB_10Rnd_770x56";
_RandomAtta = selectRandom ["LIB_ACC_No4_Mk2_Bayo", ""];
this addPrimaryWeaponItem _RandomAtta;
this addHandgunItem "LIB_1Rnd_flare_white";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "LIB_10Rnd_770x56";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_MillsBomb";};
this addItemToVest "LIB_US_M18";
this addItemToVest "fow_e_mk2";
for "_i" from 1 to 2 do {this addItemToVest "LIB_1Rnd_flare_white";};
this addItemToVest "LIB_1Rnd_flare_red";
this addItemToVest "LIB_1Rnd_flare_green";

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "LIB_Binocular_UK";

[this,"Default","male03engb"] call BIS_fnc_setIdentity;

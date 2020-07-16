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
this addHeadgear "H_LIB_UK_Beret";
/*Gogles*/
_RandomGoggles = selectRandom ["G_LIB_Binoculars", "G_LIB_Binoculars", "G_LIB_GER_Cap_Earphone", "G_LIB_GER_Cap_Earphone2", "", "", ""];
this addGoggles _RandomGoggles;
/*Uniform*/
this forceAddUniform "U_LIB_UK_P37";
/*Vest*/
this addVest "V_LIB_UK_P37_Officer";
/*Backpack*/
_RandomBackpack = selectRandom ["B_LIB_UK_HSack", "B_LIB_UK_HSack_Cape", "B_LIB_UK_HSack_Tea", "fow_b_uk_p37", "fow_b_uk_p37_radio", ""];
this addBackpack _RandomBackpack;

/*Weapon*/
_RandomWeapon = selectRandom ["LIB_Sten_Mk2", "LIB_Sten_Mk2", "LIB_Sten_Mk2", "LIB_Sten_Mk2", "LIB_Sten_Mk5"];
this addWeapon _RandomWeapon;
this addWeapon "LIB_Colt_M1911";
/*WeaponItem*/
this addPrimaryWeaponItem "lib_32rnd_9x19_sten";
_RandomAtta = selectRandom ["LIB_ACC_No4_Mk2_Bayo", ""];
this addPrimaryWeaponItem _RandomAtta;
this addHandgunItem "LIB_7Rnd_45ACP";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToVest "lib_32rnd_9x19_sten";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_7Rnd_45ACP";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_MillsBomb";};
this addItemToVest "LIB_US_M18";
this addItemToVest "fow_e_mk2";

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "LIB_Binocular_UK";

[this,"Default","male05engb"] call BIS_fnc_setIdentity;

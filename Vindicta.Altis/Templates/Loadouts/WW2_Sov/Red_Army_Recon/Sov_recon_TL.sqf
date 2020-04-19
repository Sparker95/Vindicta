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
this addHeadgear "H_LIB_SOV_RA_Helmet";
/*Uniform*/
this forceAddUniform "U_LIB_SOV_Razvedchik_am";
/*Vest*/
this addVest "V_LIB_SOV_RAZV_OfficerVest";
/*Backpack*/
this addBackpack "B_LIB_SOV_RA_GasBag";

/*Weapon*/
this addWeapon "LIB_PPSh41_m";
/*WeaponItem*/
this addPrimaryWeaponItem "LIB_71Rnd_762x25";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "LIB_71Rnd_762x25";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_Rg42";};
this addItemToVest "LIB_Rpg6";
this addItemToVest "LIB_RDG";

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "LIB_Binocular_SU";

[this,"Default","male02su"] call BIS_fnc_setIdentity;

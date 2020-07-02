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
_RandomHeadgear = selectRandom ["H_LIB_SOV_RA_PrivateCap_NKVDSE", "H_LIB_SOV_RA_PrivateCap_NKVD"];
this addHeadgear _RandomHeadgear;
/*Uniform*/
this forceAddUniform "U_LIB_SOV_NKVD_soldier_1v2pRdvM30";
/*Vest*/
this addVest "V_LIB_SOV_RA_MosinBelt";
/*Backpack*/
this addBackpack "B_LIB_SOV_RA_MedicalBag_Empty";

/*Weapon*/
_RandomWeapon = selectRandom ["LIB_M9130", "LIB_M9130", "LIB_M38", "LIB_M44"];
this addWeapon _RandomWeapon;
/*WeaponItem*/
this addPrimaryWeaponItem "lib_5rnd_762x54";
_RandomAtta = selectRandom ["LIB_ACC_M1891_Bayo", ""];
this addPrimaryWeaponItem _RandomAtta;

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 5 do {this addItemToVest "lib_5rnd_762x54";};
this addItemToBackpack "Medikit";
for "_i" from 1 to 3 do {this addItemToBackpack "FirstAidKit";};
this addItemToVest "LIB_Rg42";

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";

[this,"Default","male01su"] call BIS_fnc_setIdentity;

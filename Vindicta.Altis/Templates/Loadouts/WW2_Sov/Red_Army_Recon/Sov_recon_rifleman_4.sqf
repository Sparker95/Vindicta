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
_RandomHeadgear = selectRandom ["H_LIB_SOV_RA_Helmet", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_Helmet", "H_LIB_SOV_RA_Helmet", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_PrivateCap", "H_LIB_SOV_RA_Helmet", "H_LIB_SOV_RA_Helmet", "H_LIB_SOV_Ushanka", "H_LIB_SOV_Ushanka2"];
this addHeadgear _RandomHeadgear;
/*Uniform*/
this forceAddUniform "U_LIB_SOV_Razvedchik_am";
/*Vest*/
_RandomVest = selectRandom ["V_LIB_SOV_RAZV_PPShBelt_Mag", "V_LIB_SOV_RAZV_PPShBelt_Mag", "V_LIB_SOV_RAZV_PPShBelt_Mag", "V_LIB_SOV_IShBrVestPPShMag"];
this addVest _RandomVest;
/*Backpack*/
this addBackpack "B_LIB_SOV_RA_GasBag";

/*Weapon*/
this addWeapon "IFA3_PPS43";
/*WeaponItem*/
this addPrimaryWeaponItem "ifa3_35rnd_762x25_pps";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToVest "ifa3_35rnd_762x25_pps";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_Rg42";};
this addItemToVest "LIB_Rpg6";
this addItemToVest "LIB_RDG";

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";

[this,"Default","male03su"] call BIS_fnc_setIdentity;

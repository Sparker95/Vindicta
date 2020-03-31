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
_RandomHeadgear = selectRandom ["U_LIB_GER_Scharfschutze", "H_LIB_GER_HelmetCamo2", "H_LIB_GER_HelmetCamo", "H_LIB_GER_HelmetCamo4", "H_LIB_GER_Helmet_net_painted", "H_LIB_GER_Helmet_ns_painted", "H_LIB_GER_Helmet_os_painted", "H_LIB_GER_Helmet_painted", "H_LIB_GER_Cap"];
this addHeadgear _RandomHeadgear;
/*Gogles*/
this addGoggles "G_LIB_Binoculars";
/*Uniform*/
_RandomUniform = selectRandom ["U_LIB_GER_Soldier_camo2", "U_LIB_GER_Soldier_camo", "U_LIB_GER_Soldier_camo4", "U_LIB_GER_Soldier_camo3", "U_LIB_GER_Soldier_camo5"];
this forceAddUniform _RandomUniform;
/*Vest*/
this addVest "V_LIB_GER_VestKar98";
/*Backpack*/
_RandomBackpack = selectRandom ["B_LIB_GER_A_frame", "B_LIB_GER_A_frame_kit", "B_LIB_GER_A_frame_zeltbahn", ""];
this addBackpack _RandomBackpack;

/*Weapon*/
_RandomWeapon = selectRandom ["LIB_K98", "LIB_K98_Late"];
this addWeapon _RandomWeapon;
this addWeapon "LIB_P38";
/*WeaponItem*/
this addPrimaryWeaponItem "LIB_5Rnd_792x57";
this addHandgunItem "LIB_8Rnd_9x19";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 5 do {this addItemToVest "LIB_5Rnd_792x57";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_8Rnd_9x19";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_Shg24";};
this addItemToVest "LIB_Shg24x7";
this addItemToVest "LIB_NB39";

/*Items*/
this linkItem "ItemMap";
this linkItem "LIB_GER_ItemCompass_deg";
this linkItem "LIB_GER_ItemWatch";
this linkItem "LIB_Binocular_GER";
_RandomlinkItem = selectRandom ["N_LIB_GER_HelmetUtility_GrassOak", "N_LIB_GER_HelmetUtility_Oak", "N_LIB_GER_HelmetUtility_Grass", ""];
this linkItem _RandomlinkItem;

[this,"Default","male03ger"] call BIS_fnc_setIdentity;

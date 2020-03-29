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
_RandomHeadgear = selectRandom ["fow_h_ger_feldmutze_ss", "H_LIB_GER_Helmetnet_WSS1024T1", "H_LIB_GER_Helmetns_WSS1024T1", "H_LIB_GER_Helmet_WSS1024T1", "H_LIB_GER_Helmetnet_WSS1024T2", "H_LIB_GER_Helmetns_WSS1024T2", "H_LIB_GER_Helmet_WSS1024T2", "H_LIB_GER_Helmetnet_WSSgd", "H_LIB_GER_Helmetns_WSSgd", "H_LIB_GER_Helmetnet_WSSgdT1", "H_LIB_GER_Helmetns_WSSgdT1", "H_LIB_GER_Helmet_WSSgdT1", "H_LIB_GER_Helmetnet_WSSgdT2", "H_LIB_GER_Helmetns_WSSgdT2", "H_LIB_GER_Helmet_WSSgdT2", "H_LIB_GER_Helmet_WSSgd"];
this addHeadgear _RandomHeadgear;
/*Uniform*/
_RandomUniform = selectRandom ["U_LIB_ST_Soldier_E44", "U_LIB_ST_MGunner_E44"];
this forceAddUniform _RandomUniform;
/*Vest*/
this addVest "V_LIB_GER_VestKar98";
/*Backpack*/
_RandomBackpack = selectRandom ["B_LIB_GER_A_frame", "B_LIB_GER_A_frame_kit", "B_LIB_GER_A_frame_zeltbahn", ""];
this addBackpack _RandomBackpack;

/*Weapon*/
_RandomWeapon = selectRandom ["LIB_K98", "LIB_K98_Late", "LIB_G3340"];
this addWeapon _RandomWeapon;
/*WeaponItem*/
this addPrimaryWeaponItem "LIB_5Rnd_792x57";
_RandomAtta = selectRandom ["LIB_ACC_K98_Bayo", ""];
this addPrimaryWeaponItem _RandomAtta;

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 5 do {this addItemToVest "LIB_5Rnd_792x57";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_Shg24";};
this addItemToVest "LIB_Shg24x7";
this addItemToVest "LIB_NB39";

/*Items*/
this linkItem "ItemMap";
this linkItem "LIB_GER_ItemCompass_deg";
this linkItem "LIB_GER_ItemWatch";

[this,"Default","male05ger"] call BIS_fnc_setIdentity;

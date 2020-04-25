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
this addVest "V_LIB_GER_VestMP40";
/*Backpack*/
_RandomBackpack = selectRandom ["B_LIB_GER_A_frame", "B_LIB_GER_A_frame_kit", "B_LIB_GER_A_frame_zeltbahn", ""];
this addBackpack _RandomBackpack;

/*Weapon*/
_RandomWeapon = selectRandom ["LIB_MP38", "LIB_MP40"];
this addWeapon _RandomWeapon;
/*WeaponItem*/
this addPrimaryWeaponItem "LIB_32Rnd_9x19";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToVest "LIB_32Rnd_9x19";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_Shg24";};
this addItemToVest "LIB_Shg24x7";
this addItemToVest "LIB_NB39";

/*Items*/
this linkItem "ItemMap";
this linkItem "LIB_GER_ItemCompass_deg";
this linkItem "LIB_GER_ItemWatch";

[this,"Default","male01ger"] call BIS_fnc_setIdentity;

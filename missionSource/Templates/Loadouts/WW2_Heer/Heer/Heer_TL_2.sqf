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
this addHeadgear "H_LIB_GER_Cap";
/*Gogles*/
_RandomGoggles = selectRandom ["G_LIB_Binoculars", ""];
this addGoggles _RandomGoggles;
/*Uniform*/
_RandomUniform = selectRandom ["U_LIB_GER_Oberschutze", "U_LIB_GER_Oberschutze", "U_LIB_GER_Oberschutze", "U_LIB_GER_Oberschutze", "U_LIB_GER_Soldier3"];
this forceAddUniform _RandomUniform;
/*Vest*/
this addVest "V_LIB_GER_VestUnterofficer";
/*Backpack*/
_RandomBackpack = selectRandom ["B_LIB_GER_A_frame", "B_LIB_GER_A_frame_kit", "B_LIB_GER_A_frame_zeltbahn", "B_LIB_GER_Radio_ACRE2", ""];
this addBackpack _RandomBackpack;

/*Weapon*/
this addWeapon "LIB_G43";
this addWeapon "LIB_FLARE_PISTOL";
/*WeaponItem*/
this addPrimaryWeaponItem "fow_10nd_792x57";
this addHandgunItem "LIB_1Rnd_flare_white";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "fow_10nd_792x57";};
for "_i" from 1 to 3 do {this addItemToVest "LIB_5Rnd_792x57";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_Shg24";};
this addItemToVest "LIB_Shg24x7";
this addItemToVest "LIB_NB39";
for "_i" from 1 to 2 do {this addItemToVest "LIB_1Rnd_flare_white";};
this addItemToVest "LIB_1Rnd_flare_red";
this addItemToVest "LIB_1Rnd_flare_green";

/*Items*/
this linkItem "ItemMap";
this linkItem "LIB_GER_ItemCompass_deg";
this linkItem "LIB_GER_ItemWatch";
this linkItem "LIB_Binocular_GER";

[this,"Default","male03ger"] call BIS_fnc_setIdentity;

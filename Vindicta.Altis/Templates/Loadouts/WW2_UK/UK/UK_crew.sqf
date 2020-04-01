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
_RandomHeadgear = selectRandom ["H_LIB_UK_Beret_Tankist", "H_LIB_UK_Beret_Headset"];
this addHeadgear _RandomHeadgear;
/*Gogles*/
_RandomGoggles = selectRandom ["G_LIB_Binoculars", ""];
this  ;
/*Uniform*/
this forceAddUniform "fow_u_uk_bd40_private";
/*Vest*/
this addVest "V_LIB_GER_VestMP40";
/*Backpack*/

/*Weapon*/
this addWeapon "LIB_M3_GreaseGun";
this addWeapon "LIB_Webley_mk6";
/*WeaponItem*/
this addPrimaryWeaponItem "LIB_30Rnd_45ACP";
this addHandgunItem "LIB_6Rnd_455";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToVest "LIB_30Rnd_45ACP";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_6Rnd_455";};
this addItemToVest "LIB_NB39";

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "LIB_Binocular_UK";

[this,"Default","male05engb"] call BIS_fnc_setIdentity;

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
this addHeadgear "H_Cap_police";
/*Uniform*/
_RandomUniform = selectRandom ["APD_1", "APD_2"];
this forceaddUniform _RandomUniform;
/*Vest*/
_RandomVest = selectRandom ["S_VHO_PB_3", "S_VHO_PB_3", "S_VHO_PB_3", "S_VHO_PB_3", "S_VHO_OV_BLK_1", "S_VHO_OV_BLK_2", "S_VHO_OV_BLK_3", "S_VHO_OV_BLK_4"];
this addVest _RandomVest;
/*Backpack*/

/*Weapon*/
this addWeapon "rhsusf_weap_m9";
/*WeaponItem*/
this addHandgunItem "rhsusf_mag_15Rnd_9x19_FMJ";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToUniform "rhsusf_mag_15Rnd_9x19_FMJ";};
for "_i" from 1 to 2 do {this addItemToVest "ACE_Chemlight_HiBlue";};
for "_i" from 1 to 4 do {this addItemToVest "Chemlight_blue";};

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemGPS";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

[this,"Default","male03gre"] call BIS_fnc_setIdentity;

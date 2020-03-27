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
this addHeadgear "H_LIB_GER_OfficerCap";
/*Gogles*/
_RandomGoggles = selectRandom ["G_LIB_Binoculars", "G_LIB_Binoculars", "G_LIB_GER_Cap_Earphone", "G_LIB_GER_Cap_Earphone2", "", "", ""];
this addGoggles _RandomGoggles;
/*Uniform*/
_RandomUniform = selectRandom ["U_LIB_GER_Hauptmann", "U_LIB_GER_Leutnant", "U_LIB_GER_Oberleutnant", "U_LIB_GER_Oberst"];
this forceAddUniform _RandomUniform;
/*Vest*/
_RandomVest = selectRandom ["V_LIB_GER_FieldOfficer", "V_LIB_GER_FieldOfficer", "V_LIB_GER_OfficerBelt", "V_LIB_GER_PrivateBelt"];
this addVest _RandomVest;
/*Backpack*/

/*Weapon*/
_RandomWeapon = selectRandom ["LIB_MP38", "LIB_MP40"];
this addWeapon _RandomWeapon;
this addWeapon "LIB_M1896";
/*WeaponItem*/
this addPrimaryWeaponItem "LIB_32Rnd_9x19";
this addHandgunItem "LIB_10Rnd_9x19_M1896";
/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToVest "LIB_32Rnd_9x19";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_10Rnd_9x19_M1896";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_Shg24";};
this addItemToVest "LIB_NB39";

/*Items*/
this linkItem "ItemMap";
this linkItem "LIB_GER_ItemCompass_deg";
this linkItem "LIB_GER_ItemWatch";
this linkItem "LIB_Binocular_GER";

[this,"Default","male05ger"] call BIS_fnc_setIdentity;

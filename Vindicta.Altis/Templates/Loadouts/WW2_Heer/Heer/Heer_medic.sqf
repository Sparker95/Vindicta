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
this addHeadgear "H_LIB_GER_Helmet_Medic";
/*Uniform*/
this forceAddUniform "U_LIB_GER_Medic";
/*Vest*/
this addVest "V_LIB_GER_VestKar98";
/*Backpack*/
this addBackpack "B_LIB_GER_MedicBackpack_Empty";

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
this addItemToBackpack "Medikit";
for "_i" from 1 to 3 do {this addItemToBackpack "FirstAidKit";};

/*Items*/
this linkItem "ItemMap";
this linkItem "LIB_GER_ItemCompass_deg";
this linkItem "LIB_GER_ItemWatch";

[this,"Default","male04ger"] call BIS_fnc_setIdentity;

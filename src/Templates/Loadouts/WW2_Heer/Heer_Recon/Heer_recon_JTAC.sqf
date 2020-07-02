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
_RandomHeadgear = selectRandom ["H_LIB_GER_FSJ_M38_Helmet", "H_LIB_GER_FSJ_M38_Helmet_Cover", "H_LIB_GER_FSJ_M38_Helmet_os", "H_LIB_GER_FSJ_M44_Helmet", "H_LIB_GER_FSJ_M44_Helmet_os", "H_LIB_GER_FSJ_M44_HelmetCamo1", "H_LIB_GER_FSJ_M44_HelmetCamo2", "H_LIB_GER_FSJ_M44_HelmetUtility"];
this addHeadgear _RandomHeadgear;
/*Uniform*/
_RandomUniform = selectRandom ["U_LIB_FSJ_Soldier", "U_LIB_FSJ_Soldier_camo"];
this forceAddUniform _RandomUniform;
/*Vest*/
this addVest "V_LIB_GER_VestKar98";
/*Backpack*/
this addBackpack "B_LIB_GER_Radio_ACRE2";

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

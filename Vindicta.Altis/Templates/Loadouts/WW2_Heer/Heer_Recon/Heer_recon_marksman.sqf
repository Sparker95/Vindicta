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

/*Weapon*/
this addWeapon "LIB_K98ZF39";
this addWeapon "fow_w_p640p";
/*WeaponItem*/
this addPrimaryWeaponItem "LIB_5Rnd_792x57";
this addHandgunItem "fow_13Rnd_9x19";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 5 do {this addItemToVest "LIB_5Rnd_792x57";};
for "_i" from 1 to 3 do {this addItemToVest "fow_13Rnd_9x19";};
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

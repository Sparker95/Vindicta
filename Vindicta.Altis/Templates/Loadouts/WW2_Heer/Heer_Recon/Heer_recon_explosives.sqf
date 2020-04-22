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
this addVest "V_LIB_GER_PioneerVest";
/*Backpack*/
_RandomBackpack = selectRandom ["B_LIB_GER_SapperBackpack_empty", "B_LIB_GER_Backpack", "B_LIB_GER_Tonister34_cowhide"];
this addBackpack _RandomBackpack;

/*Weapon*/
_RandomWeapon = selectRandom ["LIB_MP38", "LIB_MP40"];
this addWeapon _RandomWeapon;
/*WeaponItem*/
this addPrimaryWeaponItem "LIB_32Rnd_9x19";

/*Items*/
this addItemToUniform "FirstAidKit";
this addItemToUniform "LIB_ToolKit";
for "_i" from 1 to 3 do {this addItemToVest "LIB_32Rnd_9x19";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_Shg24";};
this addItemToVest "LIB_Shg24x7";
this addItemToVest "LIB_NB39";
this addItemToBackpack "LIB_TMI_42_MINE_mag";
this addItemToBackpack "LIB_US_TNT_4pound_mag";
this addItemToBackpack "LIB_Ladung_Big_MINE_mag";
this addItemToBackpack "LIB_Ladung_Small_MINE_mag";
this addItemToBackpack "LIB_TM44_MINE_mag";

/*Items*/
this linkItem "ItemMap";
this linkItem "LIB_GER_ItemCompass_deg";
this linkItem "LIB_GER_ItemWatch";

[this,"Default","male01ger"] call BIS_fnc_setIdentity;

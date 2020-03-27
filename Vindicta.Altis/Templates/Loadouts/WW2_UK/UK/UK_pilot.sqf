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
_RandomHeadgear = selectRandom ["H_LIB_US_Helmet_Pilot", "H_LIB_US_Helmet_Pilot_Glasses_Down", "H_LIB_US_Helmet_Pilot_Glasses_Up", "H_LIB_UK_Helmet_Mk2_Net", "H_LIB_UK_Helmet_Mk3", "H_LIB_UK_Helmet_Mk3_Net", "fow_h_uk_jungle_hat_01", "fow_h_uk_jungle_hat_02"];
this addHeadgear _RandomHeadgear;
/*Gogles*/
_RandomGoggles = selectRandom ["G_LIB_Binoculars", ""];
this  ;
/*Uniform*/
this forceAddUniform "U_LIB_US_Pilot";
/*Vest*/
this addVest "V_LIB_US_LifeVest";
/*Backpack*/
this addBackpack "B_LIB_US_TypeA3";

/*Weapon*/
this addWeapon "LIB_P38";
/*WeaponItem*/
this addHandgunItem "LIB_8Rnd_9x19";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToVest "LIB_8Rnd_9x19";};
this addItemToVest "LIB_NB39";

/*Items*/
this linkItem "ItemMap";
this linkItem "LIB_GER_ItemCompass_deg";
this linkItem "LIB_GER_ItemWatch";
this linkItem "LIB_Binocular_GER";

[this,"Default","male04ger"] call BIS_fnc_setIdentity;

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
this addHeadgear "H_LIB_GER_LW_PilotHelmet";
/*Gogles*/
_RandomGoggles = selectRandom ["G_LIB_Binoculars", ""];
this  ;
/*Uniform*/
this forceAddUniform "U_LIB_GER_LW_pilot";
/*Vest*/
this addVest "V_LIB_GER_OfficerBelt";
/*Backpack*/
this addBackpack "B_LIB_GER_LW_Paradrop";

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

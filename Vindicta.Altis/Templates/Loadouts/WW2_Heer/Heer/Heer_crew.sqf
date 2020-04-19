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
_RandomHeadgear = selectRandom ["fow_h_ger_feldmutze_panzer", "fow_h_ger_headset", "fow_h_ger_m38_feldmutze_panzer"];
this addHeadgear _RandomHeadgear;
/*Gogles*/
_RandomGoggles = selectRandom ["G_LIB_Binoculars", ""];
this  ;
/*Uniform*/
_RandomUniform = selectRandom ["fow_u_ger_tankcrew_01_shutz", "fow_u_ger_tankcrew_01_unteroffizier"];
this forceAddUniform _RandomUniform;
/*Vest*/
this addVest "V_LIB_GER_VestMP40";
/*Backpack*/

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

[this,"Default","male03ger"] call BIS_fnc_setIdentity;

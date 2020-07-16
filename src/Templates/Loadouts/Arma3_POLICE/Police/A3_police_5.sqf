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
_RandomHeadgear = selectRandom ["H_MilCap_gen_F", "H_Cap_police"];
this addHeadgear _RandomHeadgear;
/*Uniform*/
_RandomUniform = selectRandom ["U_B_GEN_Commander_F", "U_B_GEN_Soldier_F", "U_B_GEN_Soldier_F", "U_B_GEN_Soldier_F"];
this forceAddUniform _RandomUniform;
/*Vest*/
_RandomVest = selectRandom ["V_TacVest_gen_F", "V_Rangemaster_belt", "V_Rangemaster_belt", "V_Rangemaster_belt", "V_Safety_yellow_F"];
this addVest _RandomVest;
/*Backpack*/

/*Weapon*/
this addWeapon "hgun_P07_F";
/*WeaponItem*/
this addHandgunItem "16Rnd_9x21_Mag";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToUniform "16Rnd_9x21_Mag";};
for "_i" from 1 to 2 do {this addItemToVest "ACE_Chemlight_HiBlue";};
for "_i" from 1 to 4 do {this addItemToVest "Chemlight_blue";};

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

[this,"Default","male05gre"] call BIS_fnc_setIdentity;

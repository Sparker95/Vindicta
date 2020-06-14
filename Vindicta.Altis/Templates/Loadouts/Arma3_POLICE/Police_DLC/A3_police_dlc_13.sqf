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
this addHeadgear "H_PASGT_basic_black_F";
/*Uniform*/
this forceAddUniform "U_I_G_Story_Protagonist_F";
/*Vest*/
_RandomVest = selectRandom ["V_PlateCarrier1_blk", "V_PlateCarrier2_blk"];
this addVest _RandomVest;
/*Backpack*/

/*Weapon*/
this addWeapon "arifle_AKM_F";
this addWeapon "hgun_Pistol_01_F";
/*WeaponItem*/
this addPrimaryWeaponItem "30Rnd_762x39_Mag_F";
this addHandgunItem "10Rnd_9x21_Mag";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "10Rnd_9x21_Mag";};
for "_i" from 1 to 4 do {this addItemToVest "30Rnd_762x39_Mag_F";};
_RandomItem = selectRandom ["ACE_M84", "ACE_M84", "ACE_M84", "MiniGrenade", "", "", "", "", ""];
this addItemToVest _RandomItem;
this addItemToUniform "ACE_Chemlight_HiBlue";
for "_i" from 1 to 2 do {this addItemToUniform "Chemlight_blue";};

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

[this,"Default","male01gre"] call BIS_fnc_setIdentity;

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
_RandomHeadgear = selectRandom [ "H_MilCap_blue", "H_Cap_police", "H_Cap_police"];
this addHeadgear _RandomHeadgear;
/*Uniform*/
this forceAddUniform "U_I_G_Story_Protagonist_F";
/*Vest*/
_RandomVest = selectRandom ["V_PlateCarrier1_blk", "V_PlateCarrier2_blk"];
this addVest _RandomVest;
/*Backpack*/

/*Weapon*/
this addWeapon "arifle_TRG21_F";
this addWeapon "hgun_Pistol_01_F";
/*WeaponItem*/
this addPrimaryWeaponItem "acc_flashlight";
_RandomPrimaryWeaponItem = selectRandom ["optic_ACO_grn", "optic_Holosight", "optic_Holosight_blk_F", ""];
this addPrimaryWeaponItem _RandomPrimaryWeaponItem;
this addPrimaryWeaponItem "30Rnd_556x45_Stanag";
this addHandgunItem "10Rnd_9x21_Mag";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "10Rnd_9x21_Mag";};
for "_i" from 1 to 4 do {this addItemToVest "30Rnd_556x45_Stanag";};
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

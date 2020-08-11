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
_RandomUniform = selectRandom ["U_B_GEN_Commander_F", "U_B_GEN_Soldier_F", "U_B_GEN_Soldier_F", "U_B_GEN_Soldier_F"];
this forceAddUniform _RandomUniform;
/*Vest*/
_RandomVest = selectRandom ["V_TacVest_blk_POLICE", "V_TacVest_blk_POLICE", "V_TacVest_blk_POLICE", "V_TacVest_blk_POLICE", "V_TacVestIR_blk", "V_TacVestIR_blk", "V_Chestrig_blk"];
this addVest _RandomVest;
/*Backpack*/

/*Weapon*/
this addWeapon "SMG_03C_TR_black";
this addWeapon "hgun_Pistol_01_F";
/*WeaponItem*/
this addPrimaryWeaponItem "acc_flashlight";
_RandomPrimaryWeaponItem = selectRandom ["optic_Yorris", "optic_Holosight_smg_blk_F", "", "", ""];
this addPrimaryWeaponItem _RandomPrimaryWeaponItem;
this addPrimaryWeaponItem "50Rnd_570x28_SMG_03";
this addHandgunItem "10Rnd_9x21_Mag";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToVest "10Rnd_9x21_Mag";};
for "_i" from 1 to 2 do {this addItemToVest "50Rnd_570x28_SMG_03";};
this addItemToUniform "ACE_Chemlight_HiBlue";
for "_i" from 1 to 2 do {this addItemToVest "Chemlight_blue";};

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

private _voice = [
	"male01gre", 
	"male02gre", 
	"male03gre", 
	"male04gre", 
	"male05gre"
];

[this,"Default",selectRandom _voice] call BIS_fnc_setIdentity;




comment "Exported from Arsenal by Sparker";

comment "[!] UNIT MUST BE LOCAL [!]";
if (!local this) exitWith {};

comment "Remove existing items";
removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

comment "Add weapons";
this addWeapon "SMG_03C_TR_black";
this addPrimaryWeaponItem "acc_flashlight";
this addPrimaryWeaponItem "optic_Holosight_smg_blk_F";
this addPrimaryWeaponItem "50Rnd_570x28_SMG_03";
this addWeapon "hgun_Pistol_01_F";
this addHandgunItem "10Rnd_9x21_Mag";

comment "Add containers";
this forceAddUniform "U_B_GEN_Commander_F";
this addVest "V_Chestrig_blk";

comment "Add items to containers";
this addItemToUniform "FirstAidKit";
this addItemToUniform "ACE_Chemlight_HiBlue";
for "_i" from 1 to 3 do {this addItemToVest "10Rnd_9x21_Mag";};
for "_i" from 1 to 5 do {this addItemToVest "50Rnd_570x28_SMG_03";};
for "_i" from 1 to 2 do {this addItemToVest "Chemlight_blue";};
this addHeadgear "H_MilCap_blue";

comment "Add items";
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

comment "Set identity";
[this,"Default","male05gre"] call BIS_fnc_setIdentity;

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
_RandomHeadgear = selectRandom ["H_MilCap_gen_F", "H_MilCap_gen_F", "H_Cap_police",  "H_Cap_police", "H_MilCap_gen_F", "H_PASGT_basic_blue_F", "H_PASGT_basic_black_F"];
this addHeadgear _RandomHeadgear;
/*Uniform*/
_RandomUniform = selectRandom ["U_B_GEN_Commander_F", "U_B_GEN_Soldier_F", "U_B_GEN_Soldier_F", "U_B_GEN_Soldier_F"];
this forceAddUniform _RandomUniform;
/*Vest*/
_RandomVest = selectRandom ["V_TacVest_gen_F", "V_TacVestIR_blk", "V_Chestrig_blk"];
this addVest _RandomVest;
/*Backpack*/

/*Weapon*/
this addWeapon "hgun_PDW2000_F";
this addWeapon "hgun_ACPC2_F";
/*WeaponItem*/
this addPrimaryWeaponItem "acc_flashlight";
_RandomPrimaryWeaponItem = selectRandom ["optic_Yorris", "optic_Holosight_smg_blk_F", "", "", ""];
this addPrimaryWeaponItem _RandomPrimaryWeaponItem;
this addPrimaryWeaponItem "30Rnd_9x21_Mag";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "9Rnd_45ACP_Mag";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 5 do {this addItemToUniform "9Rnd_45ACP_Mag";};
this addItemToUniform "ACE_M84";
for "_i" from 1 to 3 do {this addItemToVest "30Rnd_9x21_Mag";};
for "_i" from 1 to 2 do {this addItemToVest "ACE_Chemlight_HiBlue";};
for "_i" from 1 to 4 do {this addItemToVest "Chemlight_blue";};

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

[this,"Default","male02gre"] call BIS_fnc_setIdentity;

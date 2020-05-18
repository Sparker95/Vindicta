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
_RandomHeadgear = selectRandom ["H_PASGT_basic_black_F", "H_PASGT_basic_blue_F", "H_PASGT_basic_black_F", "H_PASGT_basic_blue_F", "H_PASGT_basic_black_F", "H_PASGT_basic_blue_F", "H_PASGT_basic_black_F"];
this addHeadgear _RandomHeadgear;
/*Uniform*/
this forceAddUniform "U_I_G_Story_Protagonist_F";
/*Vest*/
_RandomVest = selectRandom ["V_TacVest_blk_POLICE", "V_TacVest_blk_POLICE", "V_TacVest_blk_POLICE", "V_TacVestIR_blk", "V_TacVestIR_blk", "V_Chestrig_blk"];
this addVest _RandomVest;
/*Backpack*/

/*Weapon*/
this addWeapon "arifle_AKS_F";
this addWeapon "hgun_Pistol_heavy_01_F";
/*WeaponItem*/
this addPrimaryWeaponItem "30Rnd_545x39_Mag_F";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "11rnd_45acp_mag";

/*Items*/
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToVest "11rnd_45acp_mag";};
this addItemToUniform "ACE_M84";
for "_i" from 1 to 3 do {this addItemToVest "30Rnd_545x39_Mag_F";};
for "_i" from 1 to 2 do {this addItemToVest "ACE_Chemlight_HiBlue";};
for "_i" from 1 to 4 do {this addItemToVest "Chemlight_blue";};

/*Items*/
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

[this,"Default","male01gre"] call BIS_fnc_setIdentity;

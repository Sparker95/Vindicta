removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["H_Beret_gen_F","H_MilCap_gen_F","H_PASGT_basic_blue_F", "H_PASGT_basic_black_F"];
this addHeadgear _RandomHeadgear;
_RandomVest = selectRandom ["V_TacVest_gen_F", "V_Rangemaster_belt", "V_TacVestIR_blk", "V_Chestrig_blk"];
this addVest _RandomVest;
this forceAddUniform "U_B_GEN_Commander_F", "U_B_GEN_Soldier_F";

this addWeapon "SMG_05_F";
this addPrimaryWeaponItem "acc_flashlight";
this addPrimaryWeaponItem "optic_Yorris";
this addPrimaryWeaponItem "30Rnd_9x21_Mag_SMG_02";
this addWeapon "hgun_Pistol_heavy_02_F";
this addHandgunItem "acc_flashlight_pistol";
this addHandgunItem "6Rnd_45ACP_Cylinder";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "6Rnd_45ACP_Cylinder";};
this addItemToUniform "ACE_M84";
for "_i" from 1 to 3 do {this addItemToVest "30Rnd_9x21_Mag_SMG_02";};
for "_i" from 1 to 2 do {this addItemToVest "ACE_Chemlight_HiBlue";};
for "_i" from 1 to 4 do {this addItemToVest "Chemlight_blue";};

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["H_LIB_UK_Para_Helmet_Mk2_Camo", "H_LIB_UK_Para_Helmet_Mk2"];
this addHeadgear _RandomHeadgear;
this forceAddUniform "U_LIB_UK_DenisonSmock";
this addVest "V_LIB_UK_P37_Rifleman_Blanco";
this addBackpack "B_LIB_UK_HSack_Blanco", "B_LIB_UK_HSack_Blanco_Cape", "B_LIB_UK_HSack_Blanco_Tea";

this addWeapon "LIB_M1A1_Thompson";
this addPrimaryWeaponItem "LIB_30Rnd_45ACP";
this addWeapon "fow_w_welrod_mkii";
this addHandgunItem "fow_8Rnd_765x17";


this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "LIB_30Rnd_45ACP";};
for "_i" from 1 to 2 do {this addItemToVest "fow_8Rnd_765x17";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_MillsBomb";};

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";

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
_RandomBackpack = selectRandom ["B_LIB_UK_HSack_Blanco", "B_LIB_UK_HSack_Blanco_Cape", "B_LIB_UK_HSack_Blanco_Tea"];
this addBackpack _RandomBackpack;

this addWeapon "fow_w_sten_mk5";
this addPrimaryWeaponItem "fow_32Rnd_9x19_sten";


this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "fow_32Rnd_9x19_sten";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_MillsBomb";};

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";

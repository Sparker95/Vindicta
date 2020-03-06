removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["H_LIB_UK_Helmet_Mk2", "H_LIB_UK_Helmet_Mk2_Bowed"];
this addHeadgear _RandomHeadgear;
this forceAddUniform "U_LIB_UK_P37";
this addVest "V_LIB_UK_P37_Rifleman";
this addBackpack "B_LIB_UK_HSack_Cape", "B_LIB_UK_HSack", "B_LIB_UK_HSack_Tea";

this addWeapon "fow_w_sten_mk2";
this addPrimaryWeaponItem "fow_32Rnd_9x19_sten";


this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "fow_32Rnd_9x19_sten";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_MillsBomb";};

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";

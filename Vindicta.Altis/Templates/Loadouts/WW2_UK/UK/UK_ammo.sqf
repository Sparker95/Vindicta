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
this addBackpack "fow_b_uk_bergenpack";

this addWeapon "LIB_LeeEnfield_No4";
this addPrimaryWeaponItem "LIB_10Rnd_770x56";


this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "LIB_10Rnd_770x56";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_MillsBomb";};
for "_i" from 10 to 20 do {this addItemToBackpack "LIB_10Rnd_770x56";};
for "_i" from 5 to 10 do {this addItemToBackpack "LIB_32Rnd_9x19_Sten";};

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";

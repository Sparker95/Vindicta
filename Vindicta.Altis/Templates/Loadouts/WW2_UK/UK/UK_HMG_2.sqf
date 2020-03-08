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
this forceAddUniform "U_LIB_UK_P37_LanceCorporal";
this addVest "V_LIB_UK_P37_Heavy";
_RandomBackpack = selectRandom ["B_LIB_UK_HSack_Cape", "B_LIB_UK_HSack", "B_LIB_UK_HSack_Tea"];
this addBackpack _RandomBackpack;

this addWeapon "LIB_M1919A6";
this addPrimaryWeaponItem "LIB_50Rnd_762x63";


this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToBackpack "LIB_50Rnd_762x63";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_MillsBomb";};

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";

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
_RandomBackpack = selectRandom ["B_LIB_UK_HSack_Cape", "B_LIB_UK_HSack", "B_LIB_UK_HSack_Tea"];
this addBackpack _RandomBackpack;


this addItemToUniform "FirstAidKit";

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
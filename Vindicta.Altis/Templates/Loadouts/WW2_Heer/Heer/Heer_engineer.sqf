removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["H_LIB_GER_Helmet"];
this addHeadgear _RandomHeadgear;
this forceAddUniform "U_LIB_GER_Pionier";
this addVest "V_LIB_GER_PioneerVest";
this addBackpack "B_LIB_GER_Backpack";

this addWeapon "LIB_MP38";
this addPrimaryWeaponItem "LIB_32Rnd_9x19";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToVest "LIB_32Rnd_9x19";};
this addItemToBackpack "ToolKit";

this linkItem "ItemMap";
this linkItem "LIB_GER_ItemCompass_deg";
this linkItem "LIB_GER_ItemWatch";

[this,"LIB_Wolf_IF","Male01Ger"] call BIS_fnc_setIdentity;
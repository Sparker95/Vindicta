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
this forceAddUniform "U_LIB_GER_Schutze";
this addVest "V_LIB_GER_VestKar98";
this addBackpack "B_LIB_GER_Backpack";

this addWeapon "LIB_K98";
this addPrimaryWeaponItem "LIB_5Rnd_792x57";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 5 do {this addItemToVest "LIB_5Rnd_792x57";};
for "_i" from 3 to 5 do {this addItemToBackpack "LIB_10Rnd_792x57";};
for "_i" from 10 to 20 do {this addItemToBackpack "LIB_5Rnd_792x57";};
for "_i" from 5 to 10 do {this addItemToBackpack "LIB_32Rnd_9x19";};

this linkItem "ItemMap";
this linkItem "LIB_GER_ItemCompass_deg";
this linkItem "LIB_GER_ItemWatch";

[this,"LIB_Wolf_IF","Male01Ger"] call BIS_fnc_setIdentity;

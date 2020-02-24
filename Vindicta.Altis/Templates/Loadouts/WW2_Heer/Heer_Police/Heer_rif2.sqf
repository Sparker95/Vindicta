removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["H_LIB_GER_Fieldcap"];
this addHeadgear _RandomHeadgear;
this forceAddUniform "U_LIB_ST_Soldier_E44_Camo";
this addVest "V_LIB_GER_VestG43";
this addBackpack "B_LIB_GER_A_frame";

this addWeapon "fow_w_g43";
this addPrimaryWeaponItem "LIB_10Rnd_792x57";


this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "LIB_10Rnd_792x57";};
for "_i" from 1 to 4 do {this addItemToVest "LIB_5Rnd_792x57";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_Shg24";};

this linkItem "ItemMap";
this linkItem "LIB_GER_ItemCompass_deg";
this linkItem "LIB_GER_ItemWatch";

[this,"LIB_Wolf_IF","Male01Ger"] call BIS_fnc_setIdentity;

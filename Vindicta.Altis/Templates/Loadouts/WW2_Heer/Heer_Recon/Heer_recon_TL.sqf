removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["H_LIB_GER_FSJ_M38_Helmet"];
this addHeadgear _RandomHeadgear;
this forceAddUniform "U_LIB_FSJ_Soldier_camo";
this addVest "V_LIB_GER_VestMP40";

this addWeapon "fow_w_fg42";
this addPrimaryWeaponItem "LIB_20Rnd_792x57";


this addItemToUniform "FirstAidKit";
this addItemToUniform "fow_w_acc_fg42_bayo";
this addItemToVest "LIB_M39";
for "_i" from 1 to 5 do {this addItemToVest "LIB_20Rnd_792x57";};

this linkItem "ItemMap";
this linkItem "LIB_GER_ItemCompass_deg";
this linkItem "LIB_GER_ItemWatch";

[this,"LIB_Wolf_IF","Male01Ger"] call BIS_fnc_setIdentity;
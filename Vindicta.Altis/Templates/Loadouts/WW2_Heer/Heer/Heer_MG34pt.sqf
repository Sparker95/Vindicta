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
this forceAddUniform "U_LIB_GER_MG_schutze";
this addVest "V_LIB_GER_VestMG";
this addBackpack "fow_b_ammoboxes";

this addWeapon "LIB_MG34_PT";
this addPrimaryWeaponItem "LIB_75Rnd_792x57";


this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "LIB_75Rnd_792x57";};
for "_i" from 1 to 2 do {this addItemToBackpack "LIB_75Rnd_792x57";};

this linkItem "ItemMap";
this linkItem "LIB_GER_ItemCompass_deg";
this linkItem "LIB_GER_ItemWatch";

[this,"LIB_Wolf_IF","Male01Ger"] call BIS_fnc_setIdentity;
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
this addBackpack "fow_b_heer_ammo_belt";

this addWeapon "fow_w_mg34";
this addPrimaryWeaponItem "LIB_50Rnd_792x57";


this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "LIB_50Rnd_792x57";};
for "_i" from 2 to 3 do {this addItemToBackpack "LIB_50Rnd_792x57";};

this linkItem "ItemMap";
this linkItem "LIB_GER_ItemCompass_deg";
this linkItem "LIB_GER_ItemWatch";

[this,"LIB_Wolf_IF","Male01Ger"] call BIS_fnc_setIdentity;
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
this addBackpack "B_LIB_GER_A_frame";

this addWeapon "fow_w_k98";
this addPrimaryWeaponItem "LIB_5Rnd_792x57";


this addItemToUniform "FirstAidKit";
for "_i" from 2 to 7 do {this addItemToVest "LIB_5Rnd_792x57";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_Shg24";};

this linkItem "ItemMap";
this linkItem "LIB_GER_ItemCompass_deg";
this linkItem "LIB_GER_ItemWatch";

[this,"LIB_Wolf_IF","Male01Ger"] call BIS_fnc_setIdentity;
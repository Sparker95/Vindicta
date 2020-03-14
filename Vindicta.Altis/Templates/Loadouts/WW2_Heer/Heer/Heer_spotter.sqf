removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this addHeadgear "H_LIB_GER_HelmetCamo";
_RandomGoggles = selectRandom ["G_LIB_Binoculars"];
this addGoggles _RandomGoggles;
this forceAddUniform "U_LIB_GER_Scharfschutze";
this addVest "V_LIB_GER_SniperBelt";

this addWeapon "fow_w_k98_scoped";
this addPrimaryWeaponItem "LIB_5Rnd_792x57";
this addWeapon "fow_w_p640p";
this addHandgunItem "fow_13Rnd_9x19";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 5 do {this addItemToVest "LIB_5Rnd_792x57";};
for "_i" from 1 to 4 do {this addItemToVest "fow_13Rnd_9x19";};

this linkItem "ItemMap";
this linkItem "LIB_GER_ItemCompass_deg";
this linkItem "LIB_GER_ItemWatch";
this linkItem "LIB_Binocular_GER";

[this,"LIB_Wolf_IF","Male01Ger"] call BIS_fnc_setIdentity;
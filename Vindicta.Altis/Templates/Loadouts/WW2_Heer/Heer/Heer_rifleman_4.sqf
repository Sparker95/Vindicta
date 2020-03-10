removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this addHeadgear "H_LIB_GER_Helmet";
this forceAddUniform "U_LIB_GER_Schutze";
this addVest "V_LIB_GER_VestMP40";
this addBackpack "B_LIB_GER_A_frame";

this addWeapon "fow_w_stg44";
this addPrimaryWeaponItem "LIB_30Rnd_792x33";


this addItemToUniform "FirstAidKit";
this addItemToVest "LIB_NB39";
for "_i" from 2 to 4 do {this addItemToVest "LIB_30Rnd_792x33";};
for "_i" from 1 to 2 do {this addItemToVest "LIB_Shg24";};

this linkItem "ItemMap";
this linkItem "LIB_GER_ItemCompass_deg";
this linkItem "LIB_GER_ItemWatch";

[this,"LIB_Wolf_IF","Male01Ger"] call BIS_fnc_setIdentity;
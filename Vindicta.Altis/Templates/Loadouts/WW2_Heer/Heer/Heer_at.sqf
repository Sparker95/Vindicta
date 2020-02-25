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
this addVest "V_LIB_GER_VestKar98";
this addBackpack "B_LIB_GER_A_frame";

this addWeapon "ifa3_pzb39";
this addPrimaryWeaponItem "ifa3_SMKLS";
this addWeapon "LIB_M1896";
this addHandgunItem "LIB_10Rnd_9x19_M1896";


this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToVest "ifa3_SMKLS7";};

this linkItem "ItemMap";
this linkItem "LIB_GER_ItemCompass_deg";
this linkItem "LIB_GER_ItemWatch";

[this,"LIB_Wolf_IF","Male01Ger"] call BIS_fnc_setIdentity;

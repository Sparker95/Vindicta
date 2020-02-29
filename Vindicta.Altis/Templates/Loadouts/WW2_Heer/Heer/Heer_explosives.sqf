removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this addHeadgear "H_LIB_GER_Helmet";
this forceAddUniform "U_LIB_GER_Pionier";
this addVest "V_LIB_GER_PioneerVest";
this addBackpack "B_LIB_GER_SapperBackpack";

this addWeapon "LIB_MP38";
this addPrimaryWeaponItem "LIB_32Rnd_9x19";


this addItemToUniform "FirstAidKit";
this addItemToUniform "LIB_ToolKit";
for "_i" from 1 to 3 do {this addItemToVest "LIB_32Rnd_9x19";};
this addItemToBackpack "LIB_TMI_42_MINE_mag";
this addItemToBackpack "LIB_US_TNT_4pound_mag";
this addItemToBackpack "LIB_Ladung_Big_MINE_mag";
this addItemToBackpack "LIB_Ladung_Small_MINE_mag";
this addItemToBackpack "LIB_TM44_MINE_mag";

this linkItem "ItemMap";
this linkItem "LIB_GER_ItemCompass_deg";
this linkItem "LIB_GER_ItemWatch";

[this,"LIB_Wolf_IF","Male01Ger"] call BIS_fnc_setIdentity;

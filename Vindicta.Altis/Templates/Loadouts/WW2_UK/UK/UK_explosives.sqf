removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["H_LIB_UK_Helmet_Mk2_Beachgroup"];
this addHeadgear _RandomHeadgear;
this forceAddUniform "U_LIB_UK_P37";
this addVest "V_LIB_UK_P37_Gasmask";
this addBackpack "fow_b_uk_bergenpack";

this addWeapon "LIB_LeeEnfield_No4";
this addPrimaryWeaponItem "LIB_10Rnd_770x56";


this addItemToUniform "FirstAidKit";
this addItemToUniform "LIB_ToolKit";
for "_i" from 1 to 4 do {this addItemToVest "LIB_10Rnd_770x56";};
this addItemToBackpack "LIB_US_M1A1_ATMINE_mag";
this addItemToBackpack "LIB_US_TNT_4pound_mag";
this addItemToBackpack "LIB_Ladung_Big_MINE_mag";
this addItemToBackpack "LIB_Ladung_Small_MINE_mag";
this addItemToBackpack "LIB_US_M3_MINE_mag";

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";

removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomUniform = ["U_O_R_Gorka_01_F", "U_O_R_Gorka_01_brown_F"] call BIS_fnc_selectRandom;
this addUniform _RandomUniform;
_RandomHeadgear = ["rhssaf_booniehat_digital", "rhssaf_booniehat_digital", "rhssaf_bandana_digital", "rhssaf_bandana_smb", "rhs_beanie_green"] call BIS_fnc_selectRandom;
this addHeadgear _RandomHeadgear;
_RandomGoggles = ["G_Bandanna_khk", "G_Bandanna_oli", "G_Balaclava_oli", "" ] call BIS_fnc_selectRandom;
this addGoggles _RandomGoggles;

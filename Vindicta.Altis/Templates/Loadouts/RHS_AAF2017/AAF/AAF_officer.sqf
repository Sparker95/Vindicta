removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomGoggles = ["G_Aviator","",""] call BIS_fnc_selectRandom;
this addGoggles _RandomGoggles;

this addWeapon "rhs_weap_aks74un";
this addPrimaryWeaponItem "rhs_acc_pgs64_74u";
this addPrimaryWeaponItem "rhs_30Rnd_545x39_7N6M_plum_AK";
this addWeapon "hgun_Pistol_heavy_02_F";
this addHandgunItem "6Rnd_45ACP_Cylinder";

this forceAddUniform "FGN_AAF_M93_Lizard";
this addVest "rhs_vest_commander";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToUniform "6Rnd_45ACP_Cylinder";};
for "_i" from 1 to 3 do {this addItemToVest "rhs_30Rnd_545x39_7N6M_plum_AK";};
this addHeadgear "FGN_AAF_Beret";

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

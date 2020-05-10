removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomGoggles = selectRandom ["G_Aviator","",""];
this addGoggles _RandomGoggles;
this forceaddUniform "FGN_AAF_M93_Lizard";
this addVest "rhs_vest_commander";

this addWeapon "rhs_weap_m92";
this addPrimaryWeaponItem "rhs_acc_2dpZenit";
this addPrimaryWeaponItem "rhs_30Rnd_762x39mm";
this addWeapon "hgun_Pistol_heavy_02_F";
this addHandgunItem "6Rnd_45ACP_Cylinder";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToUniform "6Rnd_45ACP_Cylinder";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_30Rnd_762x39mm";};
this addHeadgear "FGN_AAF_Beret";
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
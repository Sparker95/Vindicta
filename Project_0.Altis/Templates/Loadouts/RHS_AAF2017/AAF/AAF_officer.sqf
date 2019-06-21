
removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this forceAddUniform "FGN_AAF_M93_Lizard";
this addItemToUniform "FirstAidKit";
this addVest "rhs_vest_commander";
for "_i" from 1 to 2 do {this addItemToVest "rhs_30Rnd_545x39_7N6M_plum_AK";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_9x18_8_57N181S";};
this addHeadgear "FGN_AAF_Beret";
_RandomGoggles = ["G_Aviator","",""] call BIS_fnc_selectRandom;  
  

this addGoggles _RandomGoggles;

this addWeapon "rhs_weap_aks74un";
this addPrimaryWeaponItem "rhs_acc_pgs64_74u";
this addWeapon "rhs_weap_makarov_pm";

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";




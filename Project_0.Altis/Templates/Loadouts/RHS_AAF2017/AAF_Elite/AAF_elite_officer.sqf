
removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this forceAddUniform "FGN_AAF_M10_Type07_Summer";
this addItemToUniform "FirstAidKit";
this addItemToUniform "rhs_1PN138";
this addVest "FGN_AAF_CIRAS_Crew";
for "_i" from 1 to 2 do {this addItemToVest "rhsgref_30rnd_556x45_m21";};
this addItemToVest "rhsusf_mag_17Rnd_9x19_JHP";
this addHeadgear "FGN_AAF_Beret";
_RandomGoggles = ["G_Aviator","",""] call BIS_fnc_selectRandom;  
  

this addGoggles _RandomGoggles;

this addWeapon "rhs_weap_m21s";
this addPrimaryWeaponItem "rhs_acc_2dpZenit";
this addWeapon "rhsusf_weap_glock17g4";

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";


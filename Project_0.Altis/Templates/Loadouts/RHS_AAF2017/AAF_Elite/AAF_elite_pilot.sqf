

removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this forceAddUniform "U_I_pilotCoveralls";
this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToUniform "rhs_mag_9x18_8_57N181S";};
this addItemToUniform "rhs_mag_m18_green";
_RandomHeadgear = ["rhs_zsh7a","rhs_zsh7a_alt"] call BIS_fnc_selectRandom;  
  

this addHeadgear _RandomHeadgear;
this addWeapon "rhs_weap_makarov_pm";

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";


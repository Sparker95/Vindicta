

removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this forceAddUniform "U_I_HeliPilotCoveralls";
this addItemToUniform "FirstAidKit";
this addItemToUniform "rhs_mag_m18_green";
this addVest "rhs_vest_pistol_holster";
for "_i" from 1 to 3 do {this addItemToVest "rhs_mag_9x18_8_57N181S";};
_RandomHeadgear = ["rhs_zsh7a_mike_green","rhs_zsh7a_mike_green_alt","rhs_gssh18"] call BIS_fnc_selectRandom;  
  

this addHeadgear _RandomHeadgear;
this addWeapon "rhs_weap_makarov_pm";

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
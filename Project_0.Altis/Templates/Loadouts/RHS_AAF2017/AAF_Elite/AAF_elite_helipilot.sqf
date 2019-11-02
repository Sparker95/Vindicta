removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = ["rhs_zsh7a_mike_green","rhs_zsh7a_mike_green_alt","rhs_gssh18"] call BIS_fnc_selectRandom;
this addHeadgear _RandomHeadgear;
this forceAddUniform "U_I_HeliPilotCoveralls";
this addVest "rhs_vest_pistol_holster";

this addWeapon "rhs_weap_tt33";
this addHandgunItem "rhs_mag_762x25_8";

this addItemToUniform "FirstAidKit";
this addItemToUniform "rhs_grenade_anm8_mag";
this addItemToUniform "rhs_grenade_mki_mag";
this addItemToUniform "rhs_mag_nspn_green";
this addItemToUniform "rhs_mag_762x25_8";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_762x25_8";};

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["rhs_zsh7a_mike_green","rhs_zsh7a_mike_green_alt","rhs_gssh18"];
this addHeadgear _RandomHeadgear;
this forceaddUniform "U_I_HeliPilotCoveralls";
_RandomVest = selectRandom ["FGN_AAF_M99Vest_Lizard","FGN_AAF_M99Vest_Khaki"];
this addVest _RandomVest;

this addWeapon "rhs_weap_tt33";
this addHandgunItem "rhs_mag_762x25_8";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "rhs_mag_762x25_8";};
this addItemToVest "rhs_grenade_anm8_mag";
this linkItem "ItemWatch";
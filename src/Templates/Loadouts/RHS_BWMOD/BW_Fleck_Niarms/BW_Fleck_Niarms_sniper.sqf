removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["BWA3_Booniehat_Fleck"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["rhs_googles_black","rhs_googles_clear","rhs_googles_yellow","rhs_googles_orange","rhs_ess_black"];
this addGoggles _RandomGoggles;
this forceAddUniform "BWA3_Uniform_sleeves_Fleck";
_RandomVest = selectRandom ["BWA3_Vest_Marksman_Fleck"];
this addVest _RandomVest;

this addWeapon "rhs_weap_m40a5_d";
this addPrimaryWeaponItem "rhsusf_acc_LEUPOLDMK4_d";
this addPrimaryWeaponItem "rhsusf_5Rnd_762x51_m993_Mag";
this addPrimaryWeaponItem "rhsusf_acc_harris_swivel";
this addWeapon "BWA3_P8";
this addHandgunItem "BWA3_acc_LLM01_irlaser";
this addHandgunItem "BWA3_15Rnd_9x19_P8";
this addWeapon "BWA3_Vector";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToUniform "BWA3_15Rnd_9x19_P8";};
this addItemToVest "BWA3_DM25";
this addItemToVest "BWA3_DM51A1";
for "_i" from 1 to 6 do {this addItemToVest "rhsusf_5Rnd_762x51_m118_special_Mag";};
for "_i" from 1 to 4 do {this addItemToVest "rhsusf_5Rnd_762x51_m62_Mag";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

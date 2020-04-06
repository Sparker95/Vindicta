removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["BWA3_OpsCore_Tropen"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["rhs_googles_black","rhs_googles_clear","rhs_googles_yellow","rhs_googles_orange","rhs_ess_black"];
this addGoggles _RandomGoggles;
this forceAddUniform "BWA3_Uniform_sleeves_Tropen";
_RandomVest = selectRandom ["BWA3_Vest_Marksman_Tropen"];
this addVest _RandomVest;


this addWeapon "BWA3_G28";
this addPrimaryWeaponItem "BWA3_optic_PMII_ShortdotCC";
this addPrimaryWeaponItem "BWA3_acc_VarioRay_irlaser";
this addPrimaryWeaponItem "BWA3_10Rnd_762x51_G28";
this addWeapon "BWA3_Vector";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "BWA3_10Rnd_762x51_G28";};
for "_i" from 1 to 2 do {this addItemToVest "BWA3_10Rnd_762x51_G28_AP";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["BWA3_OpsCore_Fleck"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["rhs_googles_black","rhs_googles_clear","rhs_googles_yellow","rhs_googles_orange","rhs_ess_black"];
this addGoggles _RandomGoggles;
this forceAddUniform "BWA3_Uniform_sleeves_Fleck";
_RandomVest = selectRandom ["BWA3_Vest_Rifleman_Fleck"];
this addVest _RandomVest;
this addBackpack "BWA3_Kitbag_Fleck";

this addWeapon "hlc_rifle_G36V";
this addPrimaryWeaponItem "BWA3_acc_VarioRay_irlaser";
this addPrimaryWeaponItem "rhsusf_acc_compm4";
this addPrimaryWeaponItem "hlc_30rnd_556x45_EPR_G36";
this addWeapon "BWA3_Bunkerfaust";
this addSecondaryWeaponItem "BWA3_PzF3_DM32";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "hlc_30rnd_556x45_EPR_G36";};
for "_i" from 1 to 2 do {this addItemToVest "BWA3_DM51A1";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

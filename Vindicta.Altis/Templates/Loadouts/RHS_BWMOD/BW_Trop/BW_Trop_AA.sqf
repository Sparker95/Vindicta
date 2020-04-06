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
_RandomVest = selectRandom ["BWA3_Vest_Rifleman_Tropen"];
this addVest _RandomVest;
this addBackpack "BWA3_Kitbag_Tropen";

this addWeapon "BWA3_G36A3";
this addPrimaryWeaponItem "BWA3_acc_VarioRay_irlaser";
this addPrimaryWeaponItem "rhsusf_acc_compm4";
this addPrimaryWeaponItem "BWA3_30Rnd_556x45_G36";
this addWeapon "BWA3_Fliegerfaust";
this addSecondaryWeaponItem "BWA3_Fliegerfaust_Mag";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "BWA3_30Rnd_556x45_G36";};
for "_i" from 1 to 2 do {this addItemToVest "BWA3_DM51A1";};
this addItemToBackpack "BWA3_Fliegerfaust_Mag";
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

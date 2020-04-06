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

this addWeapon "hlc_rifle_416D165";
this addPrimaryWeaponItem "rhsusf_acc_eotech_552";
this addPrimaryWeaponItem "BWA3_acc_VarioRay_irlaser";
this addPrimaryWeaponItem "hlc_30rnd_556x45_EPR";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "hlc_30rnd_556x45_EPR";};
for "_i" from 1 to 2 do {this addItemToVest "BWA3_DM51A1";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";

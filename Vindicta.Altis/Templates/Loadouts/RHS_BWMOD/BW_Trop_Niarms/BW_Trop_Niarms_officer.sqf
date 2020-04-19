removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomGoggles = selectRandom ["G_Aviator"];
this addGoggles _RandomGoggles;
this forceAddUniform "BWA3_Uniform_Crew_Tropen";
this addVest "BWA3_Vest_Leader_Tropen";

this addWeapon "hlc_rifle_416D165";
this addPrimaryWeaponItem "BWA3_acc_VarioRay_irlaser";
this addPrimaryWeaponItem "BWA3_optic_ZO4x30i_MicroT2";
this addPrimaryWeaponItem "hlc_30rnd_556x45_EPR";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToVest "hlc_30rnd_556x45_EPR";};
this addHeadgear "BWA3_Beret_Jaeger";
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "ItemGPS";

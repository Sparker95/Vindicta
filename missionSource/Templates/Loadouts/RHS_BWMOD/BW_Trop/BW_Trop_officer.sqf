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

this addWeapon "BWA3_G38_tan";
this addPrimaryWeaponItem "BWA3_acc_VarioRay_irlaser";
this addPrimaryWeaponItem "BWA3_optic_ZO4x30i_MicroT2_sand";
this addPrimaryWeaponItem "BWA3_30Rnd_556x45_G36";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToVest "BWA3_30Rnd_556x45_G36";};
this addHeadgear "BWA3_Beret_Jaeger";
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
this linkItem "ItemGPS";

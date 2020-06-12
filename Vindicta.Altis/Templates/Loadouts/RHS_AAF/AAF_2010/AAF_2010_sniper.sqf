removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomGoggles = selectRandom ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","",""];
this addGoggles _RandomGoggles;
_RandomHeadgear = selectRandom ["FGN_AAF_Boonie_Lizard","H_Bandanna_khk_hs","H_Shemag_olive_hs","H_ShemagOpen_tan"];
this addHeadgear _RandomHeadgear;
this forceaddUniform "FGN_FIA_M93_Rhodesian";
_RandomVest = selectRandom ["FGN_AAF_M99Vest_Lizard_Radio","FGN_AAF_M99Vest_Khaki_Radio"];
this addVest _RandomVest;

this addWeapon "rhs_weap_m76";
this addPrimaryWeaponItem "rhs_acc_dtk1l";
this addPrimaryWeaponItem "rhs_acc_pso1m2";
this addPrimaryWeaponItem "rhsgref_10Rnd_792x57_m76";
this addWeapon "rhs_weap_pb_6p9";
this addHandgunItem "rhs_acc_6p9_suppressor";
this addHandgunItem "rhs_mag_9x18_8_57N181S";
this addWeapon "Binocular";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 3 do {this addItemToUniform "rhs_mag_9x18_8_57N181S";};
for "_i" from 1 to 6 do {this addItemToVest "rhsgref_10Rnd_792x57_m76";};
for "_i" from 1 to 4 do {this addItemToVest "rhssaf_10Rnd_792x57_m76_tracer";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomVest = selectRandom ["V_Chestrig_rgr","rhsgref_chestrig","V_TacVest_oli","V_I_G_resistanceLeader_F"];
this addVest _RandomVest;
_RandomGoggles = selectRandom ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag_green","G_Bandanna_oli","","",""];
this addGoggles _RandomGoggles;
_RandomHeadgear = selectRandom ["FGN_AAF_Boonie_Lizard","H_Watchcap_khk","H_Shemag_olive_hs","H_Cap_headphones","H_ShemagOpen_tan"];
this addHeadgear _RandomHeadgear;
this forceaddUniform "FGN_AAF_M93_Lizard";
this addBackpack "rhs_rpg_empty";

this addWeapon "rhs_weap_m4a1_carryhandle";
this addPrimaryWeaponItem "rhsusf_acc_M952V";
this addPrimaryWeaponItem "rhs_mag_30Rnd_556x45_M855_Stanag";
this addWeapon "rhs_weap_rpg7";
this addSecondaryWeaponItem "rhs_rpg7_type69_airburst_mag";
this addWeapon "rhs_weap_tt33";
this addHandgunItem "rhs_mag_762x25_8";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "rhs_mag_762x25_8";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_mki_mag";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_mkiiia1_mag";};
for "_i" from 1 to 6 do {this addItemToVest "rhs_mag_30Rnd_556x45_M855_Stanag";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_rpg7_type69_airburst_mag";};
for "_i" from 1 to 2 do {this addItemToBackpack "RPG7_F";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
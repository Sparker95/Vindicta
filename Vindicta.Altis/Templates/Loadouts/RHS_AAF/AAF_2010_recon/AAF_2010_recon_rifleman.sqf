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
this addBackpack "FGN_AAF_Fieldpack_Lizard";

this addWeapon "rhs_weap_l1a1";
this addPrimaryWeaponItem "rhsgref_acc_falMuzzle_l1a1";
this addPrimaryWeaponItem "rhs_mag_20Rnd_762x51_m62_fnfal";
this addWeapon "rhs_weap_rpg75";
this addWeapon "rhs_weap_tt33";
this addHandgunItem "rhs_mag_762x25_8";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "rhs_mag_762x25_8";};
this addItemToVest "rhs_grenade_mki_mag";
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_mkiiia1_mag";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_20Rnd_762x51_m80a1_fnfal";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_20Rnd_762x51_m62_fnfal";};
this addItemToVest "rhs_grenade_anm8_mag";
this addItemToBackpack "rhsgref_acc_l1a1_anpvs2";
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_mag_20Rnd_762x51_m80a1_fnfal";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_mag_20Rnd_762x51_m62_fnfal";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_grenade_mkiiia1_mag";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";
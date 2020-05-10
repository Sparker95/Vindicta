removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomUniform = selectRandom ["rhsgref_uniform_ERDL","rhsgref_uniform_og107","rhsgref_uniform_og107_erdl"];
this forceaddUniform _RandomUniform;
_RandomHeadgear = selectRandom ["rhsgref_helmet_pasgt_erdl","H_Booniehat_khk_hs","H_Cap_oli_hs", "H_Cap_headphones", "H_Bandanna_khk_hs"];
this addHeadgear _RandomHeadgear;
this addVest "rhsgref_alice_webbing";

this addWeapon "rhs_weap_m4_carryhandle";
this addPrimaryWeaponItem "rhsusf_acc_M952V";
this addPrimaryWeaponItem "rhs_mag_20Rnd_556x45_M196_Stanag_Tracer_Red";
this addWeapon "rhsusf_weap_m1911a1";
this addHandgunItem "rhsusf_mag_7x45acp_MHP";
this addWeapon "Binocular";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "rhsusf_mag_7x45acp_MHP";};
for "_i" from 1 to 2 do {this addItemToUniform "Chemlight_green";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_m67";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_anm8_mag";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_mki_mag";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_20Rnd_556x45_M193_Stanag";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_20Rnd_556x45_M196_2MAG_Stanag_Tracer_Red";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_20Rnd_556x45_M196_Stanag_Tracer_Red";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
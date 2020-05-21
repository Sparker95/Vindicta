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
_RandomHeadgear = selectRandom ["H_Bandanna_khk_hs","H_Booniehat_khk_hs","H_Cap_oli_hs", "H_Booniehat_oli"];
this addHeadgear _RandomHeadgear;
_RandomVest = selectRandom ["rhsgref_chestrig","V_Chestrig_oli"];
this addVest _RandomVest;
this forceaddUniform "rhsgref_uniform_tigerstripe";

this addWeapon "rhs_weap_m3a1_specops";
this addPrimaryWeaponItem "rhsgref_30rnd_1143x23_M1T_SMG";
this addWeapon "rhsusf_weap_m1911a1";
this addHandgunItem "rhsusf_mag_7x45acp_MHP";
this addWeapon "Binocular";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToUniform "Chemlight_green";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_m67";};
this addItemToVest "rhs_grenade_mki_mag";
for "_i" from 1 to 2 do {this addItemToVest "rhsgref_30rnd_1143x23_M1T_SMG";};
this addItemToVest "rhs_grenade_anm8_mag";
this addItemToVest "rhsgref_30rnd_1143x23_M1911B_2mag_SMG";
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_mag_7x45acp_MHP";};
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
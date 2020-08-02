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
_RandomHeadgear = selectRandom ["rhsusf_cvc_green_alt_helmet","rhsusf_cvc_green_ess"];
this addHeadgear _RandomHeadgear;
this addVest "rhsgref_chestrig";

this addWeapon "rhs_weap_m3a1";
this addPrimaryWeaponItem "rhsgref_30rnd_1143x23_M1T_SMG";

this addItemToUniform "FirstAidKit";
this addItemToVest "rhs_grenade_anm8_mag";
for "_i" from 1 to 2 do {this addItemToVest "rhsgref_30rnd_1143x23_M1T_SMG";};
for "_i" from 1 to 2 do {this addItemToVest "rhsgref_30rnd_1143x23_M1T_2mag_SMG";};
this linkItem "ItemWatch";
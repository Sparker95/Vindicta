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
_RandomHeadgear = selectRandom ["rhsgref_helmet_pasgt_erdl","rhsgref_hat_M1951","H_Bandanna_khk","H_Booniehat_oli", "H_Cap_oli"];
this addHeadgear _RandomHeadgear;
this addVest "rhsgref_alice_webbing";
this addBackpack "rhs_medic_bag";

this addWeapon "rhs_weap_m3a1";
this addPrimaryWeaponItem "rhsgref_30rnd_1143x23_M1T_SMG";

for "_i" from 1 to 5 do {this addItemToUniform "FirstAidKit";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_m67";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_anm8_mag";};
for "_i" from 1 to 2 do {this addItemToVest "rhsgref_30rnd_1143x23_M1T_SMG";};
for "_i" from 1 to 2 do {this addItemToVest "rhsgref_30rnd_1143x23_M1T_2mag_SMG";};
this addItemToBackpack "Medikit";
for "_i" from 1 to 2 do {this addItemToBackpack "FirstAidKit";};
this linkItem "ItemWatch";
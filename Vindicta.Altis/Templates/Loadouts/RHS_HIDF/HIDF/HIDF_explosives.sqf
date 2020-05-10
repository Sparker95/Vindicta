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
this addBackpack "B_TacticalPack_oli";

this addWeapon "rhs_weap_m3a1";
this addPrimaryWeaponItem "rhsgref_30rnd_1143x23_M1T_SMG";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "rhsgref_30rnd_1143x23_M1T_SMG";};
for "_i" from 1 to 2 do {this addItemToVest "rhsgref_30rnd_1143x23_M1T_2mag_SMG";};
for "_i" from 1 to 4 do {this addItemToBackpack "DemoCharge_Remote_Mag";};
for "_i" from 1 to 4 do {this addItemToBackpack "rhs_grenade_m15_mag";};
this addItemToBackpack "SatchelCharge_Remote_Mag";
this linkItem "ItemWatch";
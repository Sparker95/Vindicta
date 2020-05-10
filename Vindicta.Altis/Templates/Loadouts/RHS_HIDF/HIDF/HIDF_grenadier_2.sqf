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
this addBackpack "B_FieldPack_oli";

this addWeapon "rhs_weap_m79";
this addPrimaryWeaponItem "rhs_mag_M441_HE";
this addWeapon "rhsusf_weap_m1911a1";
this addHandgunItem "rhsusf_mag_7x45acp_MHP";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "rhs_mag_m67";};
for "_i" from 1 to 3 do {this addItemToVest "rhsusf_mag_7x45acp_MHP";};
for "_i" from 1 to 12 do {this addItemToBackpack "rhs_mag_M441_HE";};
for "_i" from 1 to 6 do {this addItemToBackpack "rhs_mag_M585_white";};
this addItemToBackpack "rhs_mag_m661_green";
this addItemToBackpack "rhs_mag_m662_red";
this addItemToBackpack "rhs_mag_m713_Red";
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_mag_m714_White";};
this addItemToBackpack "rhs_mag_m715_Green";
this linkItem "ItemWatch";
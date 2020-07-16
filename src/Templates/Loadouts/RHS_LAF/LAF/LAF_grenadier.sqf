removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["rhsgref_helmet_pasgt_olive","FGN_AAF_Cap_M81","FGN_AAF_PatrolCap_M81","FGN_AAF_PASGT_M81","FGN_AAF_PASGT_M81_ESS", "FGN_AAF_PASGT_M81_ESS_2"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag_green","G_Bandanna_oli","",""];
this addGoggles _RandomGoggles;
this addVest "FGN_AAF_M99Vest_M81_Rifleman";
this forceaddUniform "rhsgref_uniform_olive";
this addBackpack "FGN_AAF_Fieldpack_M81";

this addWeapon "rhs_weap_m4a1_carryhandle_m203";
this addPrimaryWeaponItem "acc_flashlight";
_RandomSight = selectRandom ["rhsusf_acc_compm4", ""];
this addPrimaryWeaponItem _RandomSight;
this addPrimaryWeaponItem "rhs_mag_M433_HEDP";
this addPrimaryWeaponItem "rhs_mag_30Rnd_556x45_M855A1_Stanag";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_mkii_mag";};
for "_i" from 1 to 4 do {this addItemToVest "rhs_mag_30Rnd_556x45_M855A1_Stanag";};
for "_i" from 1 to 6 do {this addItemToBackpack "rhs_mag_M585_white";};
this addItemToBackpack "rhs_mag_m661_green";
this addItemToBackpack "rhs_mag_m662_red";
this addItemToBackpack "rhs_mag_m713_Red";
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_mag_m714_White";};
this addItemToBackpack "rhs_mag_m715_Green";
for "_i" from 1 to 10 do {this addItemToBackpack "rhs_mag_M433_HEDP";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_mag_M397_HET";};
this linkItem "ItemWatch";
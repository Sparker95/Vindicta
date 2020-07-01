removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["rhsgref_helmet_pasgt_olive","FGN_AAF_PASGT_M81","FGN_AAF_PASGT_M81_ESS", "FGN_AAF_PASGT_M81_ESS_2"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag_green","G_Bandanna_oli","",""];
this addGoggles _RandomGoggles;
this addVest "FGN_AAF_M99Vest_M81_Rifleman";
this forceaddUniform "rhsgref_uniform_olive";
this addBackpack "B_TacticalPack_blk";

this addWeapon "rhs_weap_m4a1_carryhandle";
this addPrimaryWeaponItem "acc_flashlight";
this addPrimaryWeaponItem "rhs_mag_30Rnd_556x45_M855A1_Stanag";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 4 do {this addItemToVest "rhs_mag_30Rnd_556x45_M855A1_Stanag";};
for "_i" from 1 to 2 do {this addItemToBackpack "DemoCharge_Remote_Mag";};
this addItemToBackpack "SatchelCharge_Remote_Mag";
for "_i" from 1 to 2 do {this addItemToBackpack "rhs_charge_tnt_x2_mag";};
this linkItem "ItemWatch";
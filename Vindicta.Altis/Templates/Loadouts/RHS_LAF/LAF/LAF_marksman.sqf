removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["rhsgref_helmet_pasgt_olive","FGN_AAF_PASGT_M81","FGN_AAF_Boonie_M81"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag_green","G_Bandanna_oli","",""];
this addGoggles _RandomGoggles;
this addVest "FGN_AAF_M99Vest_M81";
this forceaddUniform "rhsgref_uniform_olive";

this addWeapon "rhs_weap_m14ebrri";
this addPrimaryWeaponItem "acc_flashlight";
this addPrimaryWeaponItem "rhsusf_acc_LEUPOLDMK4";
this addPrimaryWeaponItem "rhsusf_20Rnd_762x51_m118_special_Mag";
this addPrimaryWeaponItem "rhsusf_acc_harris_bipod";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_20Rnd_762x51_m118_special_Mag";};
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_20Rnd_762x51_m62_Mag";};
this linkItem "ItemWatch";
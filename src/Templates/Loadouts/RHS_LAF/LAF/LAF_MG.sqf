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
this addVest "FGN_AAF_M99Vest_M81";
this forceaddUniform "rhsgref_uniform_olive";
this addBackpack "FGN_AAF_FAST_M81";

this addWeapon "rhs_weap_m240G";
this addPrimaryWeaponItem "rhsusf_acc_ARDEC_M240";
this addPrimaryWeaponItem "rhsusf_50Rnd_762x51";

this addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_50Rnd_762x51";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhsusf_100Rnd_762x51";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhsusf_100Rnd_762x51_m62_tracer";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhsusf_50Rnd_762x51_m62_tracer";};
this linkItem "ItemWatch";
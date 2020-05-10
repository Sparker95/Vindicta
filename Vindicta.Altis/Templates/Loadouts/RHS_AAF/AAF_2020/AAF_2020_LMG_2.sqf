removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomVest = selectRandom ["FGN_AAF_CIRAS_SAW","FGN_AAF_CIRAS_SAW_Belt","FGN_AAF_CIRAS_SAW_Belt_CamB","FGN_AAF_CIRAS_SAW_CamB"];
this addVest _RandomVest;
_RandomHeadgear = selectRandom ["FGN_AAF_PASGT","FGN_AAF_PASGT_ESS","FGN_AAF_PASGT_ESS_2","FGN_AAF_PASGT_Type07","FGN_AAF_PASGT_Type07_ESS","FGN_AAF_PASGT_Type07_ESS_2"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","","",""];
this addGoggles _RandomGoggles;
this forceaddUniform "FGN_AAF_M10_Type07_Summer";
this addBackpack "FGN_AAF_UMTBS_Type07";

this addWeapon "rhs_weap_m249";
this addPrimaryWeaponItem "rhsusf_100Rnd_556x45_M855_mixed_soft_pouch_coyote";
this addPrimaryWeaponItem "rhsusf_acc_saw_bipod";

this addItemToUniform "FirstAidKit";
this addItemToUniform "FGN_AAF_PatrolCap_Type07";
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_mkii_mag";};
for "_i" from 1 to 2 do {this addItemToVest "rhsusf_100Rnd_556x45_M855_mixed_soft_pouch_coyote";};
for "_i" from 1 to 2 do {this addItemToBackpack "rhsusf_200Rnd_556x45_M855_mixed_soft_pouch_coyote";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";



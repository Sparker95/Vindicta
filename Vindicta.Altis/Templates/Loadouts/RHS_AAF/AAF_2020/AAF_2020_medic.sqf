removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

_RandomHeadgear = selectRandom ["FGN_AAF_PASGT","FGN_AAF_PASGT_ESS","FGN_AAF_PASGT_ESS_2","FGN_AAF_PASGT_Type07","FGN_AAF_PASGT_Type07_ESS","FGN_AAF_PASGT_Type07_ESS_2"];
this addHeadgear _RandomHeadgear;
_RandomGoggles = selectRandom ["FGN_AAF_Shemag_tan","FGN_AAF_Shemag","rhs_scarf","","",""];
this addGoggles _RandomGoggles;
this forceaddUniform "FGN_AAF_M10_Type07_Summer";
this addVest "FGN_AAF_CIRAS_Medic";
this addBackpack "FGN_AAF_Bergen_Medic_Type07";

this addWeapon "rhs_weap_m21s";
this addPrimaryWeaponItem "rhsgref_30rnd_556x45_m21";
this addPrimaryWeaponItem "rhs_acc_2dpZenit";

this addItemToUniform "FirstAidKit";
this addItemToUniform "FGN_AAF_PatrolCap_Type07";
for "_i" from 1 to 4 do {this addItemToVest "rhsgref_30rnd_556x45_m21";};
for "_i" from 1 to 2 do {this addItemToVest "rhs_grenade_mkii_mag";};
this addItemToVest "rhs_grenade_anm8_mag";
this addItemToBackpack "Medikit";
for "_i" from 1 to 20 do {this addItemToBackpack "FirstAidKit";};
this linkItem "ItemWatch";
this linkItem "ItemRadio";

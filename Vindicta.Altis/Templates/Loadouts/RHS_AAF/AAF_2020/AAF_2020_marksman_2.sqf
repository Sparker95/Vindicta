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
this forceAddUniform "FGN_AAF_M10_Type07_Summer";
this addVest "FGN_AAF_CIRAS_MM";

private _Primary = [
	["rhs_weap_SCARH_FDE_STD", "rhs_mag_20Rnd_SCAR_762x51_m80a1_epr"], 0.4,
	["rhs_weap_SCARH_FDE_LB", "rhs_mag_20Rnd_SCAR_762x51_m80a1_epr"],  0.3,
	["rhs_weap_SCARH_FDE_CQC", "rhs_mag_20Rnd_SCAR_762x51_m80a1_epr"], 0.3
];

(selectRandomWeighted _Primary) params ["_gun", "_ammo"];
this addWeapon _gun;
this addPrimaryWeaponItem _ammo;
for "_i" from 1 to 6 do {this addItemToVest _ammo;};
_RandomSight = selectRandom ["rhsusf_acc_su230a_c", "rhsusf_acc_su230a_mrds_c", "rhsusf_acc_g33_xps3"];
this addPrimaryWeaponItem _RandomSight;
this addPrimaryWeaponItem "rhsusf_acc_grip2";
this addWeapon "rhssaf_zrak_rd7j";

this addItemToUniform "FirstAidKit";
this addItemToUniform "FGN_AAF_PatrolCap_Type07";
this linkItem "ItemWatch";
this linkItem "ItemRadio";
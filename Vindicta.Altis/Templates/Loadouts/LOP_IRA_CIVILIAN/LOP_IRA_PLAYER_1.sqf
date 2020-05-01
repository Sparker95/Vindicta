removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

[this, selectRandom gVanillaFaces, "ace_novoice"] call BIS_fnc_setIdentity;

/*Headgear*/
if (random 10 < 3) then {
	private _headgear = [
	"LOP_H_Villager_cap",
	"PO_H_cap_tub",
	"PO_H_bonnie_tub",
	"H_Beret_blk"
	];

	this addHeadgear selectRandom _headgear;
};

/*Uniform*/
this forceAddUniform selectRandom [
	"LOP_U_CHR_Functionary_01",
	"LOP_U_CHR_Functionary_02",
	"LOP_U_CHR_Citizen_03",
	"LOP_U_CHR_Citizen_04",
	"LOP_U_CHR_Citizen_01",
	"LOP_U_CHR_Citizen_02",
	"LOP_U_CHR_Citizen_05",
	"LOP_U_CHR_Citizen_06",
	"LOP_U_CHR_Citizen_07",
	"LOP_U_CHR_Villager_01",
	"LOP_U_CHR_Villager_02",
	"LOP_U_CHR_Villager_03",
	"LOP_U_CHR_Villager_04",
	"LOP_U_CHR_Profiteer_01",
	"LOP_U_CHR_Profiteer_02",
	"LOP_U_CHR_Profiteer_03",
	"LOP_U_CHR_Profiteer_04",
	"LOP_U_CHR_SchoolTeacher_01",
	"LOP_U_PMC_floral",
	"LOP_U_PMC_tacky",
	"LOP_U_PMC_blue_plaid",
	"LOP_U_PMC_grn_plaid",
	"LOP_U_PMC_orng_plaid",
	"LOP_U_PMC_red_plaid",
	"LOP_U_CHR_Woodlander_01",
	"LOP_U_CHR_Worker_01",
	"LOP_U_CHR_Worker_02",
	"LOP_U_CHR_Worker_03",
	"LOP_U_BH_Fatigue_GUE_FWDL", 
	"LOP_U_BH_Fatigue_FWDL", 
	"LOP_U_IRA_Fatigue_DPM",
	"LOP_U_IRA_Fatigue_HTR_DPM_J",
	"LOP_U_IRA_Fatigue_HTR_DPM",
	"LOP_U_ISTS_Fatigue_18",
	"LOP_U_BH_Fatigue_M81"
	"LOP_U_CHR_Worker_04"
];

if(random 10 > 5) then { this linkItem "ItemWatch" };

private _gunsAndAmmo = [
	// pistols
	["rhsusf_weap_m9",			"rhsusf_mag_15Rnd_9x19_JHP",	true],	0.9,
	["rhsusf_weap_m1911a1",		"rhsusf_mag_7x45acp_MHP",		true],	0.7,
	["rhs_weap_makarov_pm",		"rhs_mag_9x18_8_57N181S",		true],	0.7,
	["rhs_weap_savz61_folded",	"rhsgref_20rnd_765x17_vz61",	true],	0.2,
	// long
	["rhs_weap_m1garand_sa43",	"rhsgref_8Rnd_762x63_M2B_M1rifle",	true],	0.1,
	["rhs_weap_kar98k",			"rhsgref_5Rnd_792x57_kar98k",		true],	0.1,
	["rhs_weap_m38",			"rhsgref_5Rnd_762x54_m38",			true],	0.1
];

this forceAddUniform selectRandom _uniforms;

(selectRandomWeighted _gunsAndAmmo) params ["_gun", "_ammo", "_isPistol"];

this addWeapon _gun;

if(_isPistol) then {
	this addHandgunItem _ammo;
} else {
	this addWeaponItem [_gun, _ammo];
};

for "_i" from 1 to 5 do { this addItemToUniform _ammo };



this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";

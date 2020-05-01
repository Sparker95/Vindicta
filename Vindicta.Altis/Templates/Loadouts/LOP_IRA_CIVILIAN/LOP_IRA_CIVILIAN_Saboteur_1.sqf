removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

[this, selectRandom gVanillaFaces, "ace_novoice"] call BIS_fnc_setIdentity;

// ==== Headgear ====
private _headgear = [
	"LOP_H_Villager_cap",
	"PO_H_cap_tub",
	"PO_H_bonnie_tub",
	"H_Beret_blk"
];

this addHeadgear selectRandom _headgear;

//	==== Uniform ====
private _uniforms = [
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
	"LOP_U_CHR_Worker_04"
];

this forceAddUniform selectRandom _uniforms;

// ==== Backpack ====
private _backpacks = [
	"B_Kitbag_rgr",
	"B_AssaultPack_rgr"
];

this addBackpack selectRandom _backpacks;
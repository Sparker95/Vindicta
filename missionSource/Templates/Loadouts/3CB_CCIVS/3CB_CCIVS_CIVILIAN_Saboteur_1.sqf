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
	"UK3CB_H_Beanie_01",
	"H_Cap_blk",
	"H_Cap_grn"
];

this addHeadgear selectRandom _headgear;

//	==== Uniform ====
private _uniforms = [
	"UK3CB_CHC_C_U_HIKER_01",
	"UK3CB_CHC_C_U_HIKER_02",
	"UK3CB_CHC_C_U_HIKER_03",
	"UK3CB_CHC_C_U_HIKER_04",
	"UK3CB_CHC_C_U_ACTIVIST_01",
	"UK3CB_CHC_C_U_ACTIVIST_02",
	"UK3CB_CHC_C_U_ACTIVIST_03",
	"UK3CB_CHC_C_U_ACTIVIST_04",
	"UK3CB_CHC_C_U_CIT_01",
	"UK3CB_CHC_C_U_CIT_02",
	"UK3CB_CHC_C_U_CIT_03",
	"UK3CB_CHC_C_U_CIT_04",
	"UK3CB_CHC_C_U_COACH_01",
	"UK3CB_CHC_C_U_COACH_02",
	"UK3CB_CHC_C_U_COACH_03",
	"UK3CB_CHC_C_U_COACH_04",
	"UK3CB_CHC_C_U_COACH_05",
	"UK3CB_CHC_C_U_WORK_01",
	"UK3CB_CHC_C_U_WORK_02",
	"UK3CB_CHC_C_U_WORK_03",
	"UK3CB_CHC_C_U_WORK_04",
	"UK3CB_CHC_C_U_PROF_01",
	"UK3CB_CHC_C_U_PROF_02",
	"UK3CB_CHC_C_U_PROF_03",
	"UK3CB_CHC_C_U_PROF_04",
	"UK3CB_CHC_C_U_VILL_01",
	"UK3CB_CHC_C_U_VILL_02",
	"UK3CB_CHC_C_U_VILL_03",
	"UK3CB_CHC_C_U_VILL_04",
	"UK3CB_CHC_C_U_WOOD_01",
	"UK3CB_CHC_C_U_WOOD_02",
	"UK3CB_CHC_C_U_WOOD_03",
	"UK3CB_CHC_C_U_WOOD_04"
];

this forceAddUniform selectRandom _uniforms;

// ==== Backpack ====
private _backpacks = [
	"UK3CB_B_Alice_Bedroll_K",
	"UK3CB_B_Alice_K"
];

this addBackpack selectRandom _backpacks;
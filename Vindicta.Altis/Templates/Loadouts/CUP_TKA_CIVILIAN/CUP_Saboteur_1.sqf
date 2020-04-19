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
private _lungeHeadGearFront = [
	"CUP_H_TKI_Lungee_Open_01",
	"CUP_H_TKI_Lungee_01",
	"CUP_H_TKI_Lungee_02",
	"CUP_H_TKI_Lungee_03",
	"CUP_H_TKI_Lungee_04",
	"CUP_H_TKI_Lungee_05",
	"CUP_H_TKI_Lungee_06"
];

this addHeadgear selectRandom _lungeHeadGearFront;

// ==== Uniform =====
private _jeansUniform = selectRandom[
	"CUP_O_TKI_Khet_Jeans_01",
	"CUP_O_TKI_Khet_Jeans_02",
	"CUP_O_TKI_Khet_Jeans_03",
	"CUP_O_TKI_Khet_Jeans_04"
];
private _partugUniform = selectRandom[
	"CUP_O_TKI_Khet_Partug_01",
	"CUP_O_TKI_Khet_Partug_02",
	"CUP_O_TKI_Khet_Partug_03",
	"CUP_O_TKI_Khet_Partug_04",
	"CUP_O_TKI_Khet_Partug_05",
	"CUP_O_TKI_Khet_Partug_06",
	"CUP_O_TKI_Khet_Partug_07",
	"CUP_O_TKI_Khet_Partug_08"
];

this forceAddUniform selectRandom[_jeansUniform, _partugUniform];

// ==== Vest ====
private _waistVest = selectRandom[
	"CUP_V_OI_TKI_Jacket6_06",
	"CUP_V_OI_TKI_Jacket6_05",
	"CUP_V_OI_TKI_Jacket6_04"
];
private _wlightVest = selectRandom[
	"CUP_V_OI_TKI_Jacket5_06",
	"CUP_V_OI_TKI_Jacket5_05",
	"CUP_V_OI_TKI_Jacket5_04"
];
private _jacketVest = selectRandom[
	"CUP_V_OI_TKI_Jacket1_05",
	"CUP_V_OI_TKI_Jacket1_06",
	"CUP_V_OI_TKI_Jacket1_04"
];
this addVest selectRandom [_waistVest, _wlightVest, _jacketVest];

// ==== Backpack ====
private _backpacks = [
	"CUP_B_IDF_Backpack",
	"CUP_B_SLA_Medicbag"
];

this addBackpack selectRandom _backpacks;
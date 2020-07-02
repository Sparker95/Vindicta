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
private _lungeHeadGear = selectRandom[
	"CUP_H_TKI_Lungee_Open_01",
	"CUP_H_TKI_Lungee_Open_02",
	"CUP_H_TKI_Lungee_Open_03",
	"CUP_H_TKI_Lungee_Open_04",
	"CUP_H_TKI_Lungee_Open_05",
	"CUP_H_TKI_Lungee_Open_06"
];
private _lungeHeadGearFront = selectRandom[
	"CUP_H_TKI_Lungee_Open_01",
	"CUP_H_TKI_Lungee_01",
	"CUP_H_TKI_Lungee_02",
	"CUP_H_TKI_Lungee_03",
	"CUP_H_TKI_Lungee_04",
	"CUP_H_TKI_Lungee_05",
	"CUP_H_TKI_Lungee_06"
];

private _pakolHeadGear = selectRandom[
	"CUP_H_TKI_Pakol_2_03",
	"CUP_H_TKI_Pakol_2_02",
	"CUP_H_TKI_Pakol_2_01",
	"CUP_H_TKI_Pakol_1_06",
	"CUP_H_TKI_Pakol_1_05",
	"CUP_H_TKI_Pakol_1_04",
	"CUP_H_TKI_Pakol_1_03",
	"CUP_H_TKI_Pakol_2_06",
	"CUP_H_TKI_Pakol_2_05",
	"CUP_H_TKI_Pakol_2_04",
	"CUP_H_TKI_Pakol_1_01"
];
private _capHeadGearFront = selectRandom[
	"CUP_H_TKI_SkullCap_06",
	"CUP_H_TKI_SkullCap_05",
	"CUP_H_TKI_SkullCap_04",
	"CUP_H_TKI_SkullCap_03",
	"CUP_H_TKI_SkullCap_02",
	"CUP_H_TKI_SkullCap_01"
];

this addHeadgear selectRandom [_lungeHeadGear, _lungeHeadGearFront,_pakolHeadGear,_capHeadGearFront];

//==== Facegear ====
if(random 10 < 3) then { 
	this addGoggles (selectRandom [
		"CUP_G_TK_RoundGlasses_gold",
		"CUP_G_TK_RoundGlasses_blk",
		"CUP_G_TK_RoundGlasses"
	]);
};

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
this forceAddUniform selectRandom [_jeansUniform, _partugUniform];

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
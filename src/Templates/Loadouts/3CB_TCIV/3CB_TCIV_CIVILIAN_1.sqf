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
private _HeadGear = selectRandom[
	"UK3CB_TKC_H_Turban_01_1",
	"UK3CB_TKC_H_Turban_02_1",
	"UK3CB_TKC_H_Turban_06_1",
	"UK3CB_TKC_H_Turban_03_1",
	"UK3CB_TKC_H_Turban_04_1",
	"UK3CB_TKC_H_Turban_05_1"
];

this addHeadgear selectRandom [_HeadGear];

//==== Facegear ====
if(random 10 < 3) then { 
	this addGoggles (selectRandom [
	"UK3CB_G_Face_Wrap_01",
	"G_Aviator"	// Yes! Yes!
	]);
};

// ==== Uniform =====
private _Uniform = selectRandom[
	"UK3CB_TKC_C_U_01",
	"UK3CB_TKC_C_U_01_B",
	"UK3CB_TKC_C_U_01_C",
	"UK3CB_TKC_C_U_01_D",
	"UK3CB_TKC_C_U_01_E",
	"UK3CB_TKC_C_U_02",
	"UK3CB_TKC_C_U_02_B",
	"UK3CB_TKC_C_U_02_C",
	"UK3CB_TKC_C_U_02_D",
	"UK3CB_TKC_C_U_02_E",
	"UK3CB_TKC_C_U_03",
	"UK3CB_TKC_C_U_03_B",
	"UK3CB_TKC_C_U_03_C",
	"UK3CB_TKC_C_U_03_D",
	"UK3CB_TKC_C_U_03_E",
	"UK3CB_TKC_C_U_06",
	"UK3CB_TKC_C_U_06_B",
	"UK3CB_TKC_C_U_06_C",
	"UK3CB_TKC_C_U_06_D",
	"UK3CB_TKC_C_U_06_E"
];

this forceAddUniform selectRandom [_Uniform];
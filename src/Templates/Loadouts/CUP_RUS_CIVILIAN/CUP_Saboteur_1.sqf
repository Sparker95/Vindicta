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
	"CUP_H_FR_BandanaGreen",
	"CUP_H_FR_BandanaWdl",
	"CUP_H_PMC_Beanie_Black",
	"CUP_H_SLA_BeanieGreen",
	"CUP_H_PMC_Beanie_Khaki",
	"CUP_H_C_Beanie_02",
	"CUP_H_C_Beanie_04"
];

this addHeadgear selectRandom _headgear;

//	==== Uniform ====
private _uniforms = [
	"CUP_U_C_Worker_01",
	"CUP_U_C_Woodlander_01",
	"CUP_U_C_Villager_01",
	"CUP_U_C_Functionary_jacket_01",
	"CUP_U_C_Suit_01",
	"CUP_U_C_Rocker_01",
	"CUP_U_C_Priest_01",
	"CUP_U_C_Citizen_01",
	"CUP_U_C_Mechanic_01",
	"CUP_U_C_racketeer_01",
	"CUP_U_C_Profiteer_01",
	"CUP_U_O_CHDKZ_Lopotev"
];

this forceAddUniform selectRandom _uniforms;

// ==== Backpack ====
private _backpacks = [
	"CUP_B_HikingPack_Civ",
	"CUP_B_CivPack_WDL",
	"CUP_B_IDF_Backpack"
];

this addBackpack selectRandom _backpacks;
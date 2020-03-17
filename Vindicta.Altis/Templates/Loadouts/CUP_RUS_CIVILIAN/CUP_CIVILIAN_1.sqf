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
if (random 10 < 3) then {
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
};

// ==== Uniform ====
private _citizenUniform = selectRandom[
	"CUP_U_C_Citizen_01",
	"CUP_U_C_Citizen_02",
	"CUP_U_C_Citizen_03",
	"CUP_U_C_Citizen_04"
];
private _mechanicUniform = selectRandom[
	"CUP_U_C_Mechanic_01",
	"CUP_U_C_Mechanic_02",
	"CUP_U_C_Mechanic_03"
];
private _racketeerUniform = selectRandom[
	"CUP_U_C_racketeer_01",
	"CUP_U_C_racketeer_02",
	"CUP_U_C_racketeer_03",
	"CUP_U_C_racketeer_04"
];
private _rockerUniform = selectRandom[
	"CUP_U_C_Rocker_01",
	"CUP_U_C_Rocker_02",
	"CUP_U_C_Rocker_03",
	"CUP_U_C_Rocker_04"
];
private _suitUniform = selectRandom[
	"CUP_U_C_Suit_01",
	"CUP_U_C_Suit_02",
	"CUP_U_C_Suit_03"
];
private _jacketUniform = selectRandom[
	"CUP_U_C_Functionary_jacket_01",
	"CUP_U_C_Functionary_jacket_02",
	"CUP_U_C_Functionary_jacket_03"
];
private _villagerUniform = selectRandom[
	"CUP_U_C_Villager_01",
	"CUP_U_C_Villager_02",
	"CUP_U_C_Villager_03",
	"CUP_U_C_Villager_04"
];
private _woodlanderUniform = selectRandom[
	"CUP_U_C_Woodlander_01",
	"CUP_U_C_Woodlander_02",
	"CUP_U_C_Woodlander_03",
	"CUP_U_C_Woodlander_04"
];
private _workerUniform = selectRandom[
	"CUP_U_C_Worker_01",
	"CUP_U_C_Worker_02",
	"CUP_U_C_Worker_03",
	"CUP_U_C_Worker_04"
];

private _uniforms = [
	"CUP_U_C_Priest_01",
	_citizenUniform,
	_mechanicUniform,
	_racketeerUniform,
	_rockerUniform,
	_suitUniform,
	_jacketUniform,
	_villagerUniform,
	_woodlanderUniform,
	_workerUniform
];

this forceAddUniform selectRandom _uniforms;
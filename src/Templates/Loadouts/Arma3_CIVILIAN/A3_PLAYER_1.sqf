removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

[this, selectRandom gVanillaFaces, "ace_novoice"] call BIS_fnc_setIdentity;

private _uniforms = [
	"U_C_Poloshirt_blue",
	"U_C_Poloshirt_burgundy",
	"U_C_Poloshirt_redwhite",
	"U_C_Poloshirt_salmon",
	"U_C_Poloshirt_stripped",
	"U_C_Poloshirt_tricolour",
	"U_Marshal"
];

private _gunsAndAmmo = [
	// pistols
	["hgun_Pistol_heavy_01_F", 	"11Rnd_45ACP_Mag", 		true],	1,
	["hgun_ACPC2_F", 			"9Rnd_45ACP_Mag", 		true],	0.9,
	["hgun_P07_F", 				"16Rnd_9x21_Mag", 		true],	0.8,
	["hgun_Rook40_F", 			"16Rnd_9x21_Mag", 		true],	0.7,
	// longs
	["hgun_PDW2000_F", 			"30Rnd_9x21_Mag", 		false],	0.1
];

private _ownedDLCs = getDLCs 1;
// Apex
if(395180 in _ownedDLCs) then {
	_uniforms = _uniforms + [
		"U_I_C_Soldier_Bandit_5_F",
		"U_I_C_Soldier_Bandit_3_F",
		"U_C_Man_casual_1_F",
		"U_C_Man_casual_2_F",
		"U_C_Man_casual_3_F",
		"U_C_man_sport_2_F",
		"U_C_Man_casual_6_F",
		"U_C_Man_casual_4_F",
		"U_C_Man_casual_5_F"
	];
	_gunsAndAmmo = _gunsAndAmmo + [
		// pistols
		["hgun_Pistol_01_F", 	"10Rnd_9x21_Mag", 		true],	0.7,
		["hgun_P07_khk_F", 		"16Rnd_9x21_Mag", 		true],	0.7,
		["arifle_AKM_F", 		"30rnd_762x39_mag_f", 	false],	0.01,
		["arifle_AKS_F", 		"30rnd_545x39_mag_f", 	false],	0.01
	];
};

// Contact
if(1021790 in _ownedDLCs) then {
	_uniforms = _uniforms + [
		"U_C_Uniform_Farmer_01_F",
		"U_C_E_LooterJacket_01_F",
		"U_I_L_Uniform_01_tshirt_black_F",
		"U_I_L_Uniform_01_tshirt_skull_F",
		"U_I_L_Uniform_01_tshirt_sport_F",
		"U_C_Uniform_Scientist_01_formal_F",
		"U_C_Uniform_Scientist_01_F",
		"U_C_Uniform_Scientist_02_formal_F",
		"U_O_R_Gorka_01_black_F"
	];
	_gunsAndAmmo = _gunsAndAmmo + [
		// longs
		["sgun_HunterShotgun_01_F", 			"2Rnd_12Gauge_Pellets",		false],	0.3,
		["sgun_HunterShotgun_01_sawedoff_F", 	"2Rnd_12Gauge_Pellets", 	false], 0.3,
		["srifle_DMR_06_hunter_F", 				"10Rnd_Mk14_762x51_Mag", 	false], 0.2
	];
};

// Laws of War
if(1021790 in _ownedDLCs) then {
	_uniforms = _uniforms + [
		"U_C_Mechanic_01_F"
	];
};

this forceAddUniform selectRandom _uniforms;

(selectRandomWeighted _gunsAndAmmo) params ["_gun", "_ammo", "_isPistol"];

this addWeapon _gun;

if(_isPistol) then {
	this addHandgunItem "acc_flashlight_pistol";
	this addHandgunItem _ammo;
} else {
	this addWeaponItem [_gun, "acc_flashlight"];
	this addWeaponItem [_gun, _ammo];
};

for "_i" from 1 to 5 do { this addItemToUniform _ammo };

this addHeadgear "H_Bandanna_gry";

if(random 5 < 1) then {
	this addGoggles selectRandomWeighted [
		"G_Spectacles", 		1,
		"G_Sport_Red", 			1,
		"G_Squares_Tinted", 	1,
		"G_Squares", 			1,
		"G_Spectacles_Tinted", 	1,
		"G_Shades_Black", 		1,
		"G_Shades_Blue", 		1,
		"G_Aviator", 			0.01
	];
};

this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";

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
	"gm_gc_civ_uniform_man_01_80_blk",
	"gm_gc_civ_uniform_man_01_80_blu",
	"gm_gc_civ_uniform_man_02_80_brn",
	"gm_ge_civ_uniform_blouse_80_gry"
];

private _gunsAndAmmo = [
	// pistols
	["gm_pm_blk", 		"gm_8Rnd_9x18mm_B_pst_pm_blk",					true],	0.9,
	//smg
	["gm_mp2a1_blk", 		"gm_32Rnd_9x19mm_B_DM11_mp2_blk",	false], 0.2,
	// rifle
	["gm_mpiaks74n_brn",	"gm_30Rnd_545x39mm_B_7N6_ak74_org",	false],	0.1
];

this forceAddUniform selectRandom _uniforms;

(selectRandomWeighted _gunsAndAmmo) params ["_gun", "_ammo", "_isPistol"];

this addWeapon _gun;

if(_isPistol) then {
	this addHandgunItem _ammo;
} else {
	this addWeaponItem [_gun, _ammo];
};

for "_i" from 1 to 3 do { this addItemToUniform _ammo };
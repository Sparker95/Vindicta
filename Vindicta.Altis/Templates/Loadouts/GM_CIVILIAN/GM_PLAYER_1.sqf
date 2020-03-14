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
	"gm_ge_civ_uniform_blouse_80_gry",
	"gm_ge_ff_uniform_man_80_orn",
	"gm_ge_dbp_uniform_suit_80_blu"
];

private _gunsAndAmmo = [
	// pistols
	["gm_pm_blk", 		"gm_8Rnd_9x18mm_B_pst_pm_blk", 			true],	0.9,
	// flaregun
	["gm_lp1_blk",		"gm_1Rnd_265mm_flare_single_red_gc", 	true], 0.3,
	// smg
	["gm_mp2a1_blk", 	"gm_32Rnd_9x19mm_B_DM11_mp2_blk",		false], 0.1
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
this addItemToUniform "ACE_Flashlight_Maglite_ML300L";

if(random 5 < 2) then {
	this addGoggles selectRandomWeighted [
		"G_Squares", 			1
	];
};

this linkItem "ItemMap";
if(random 10 > 5) then { this linkItem "gm_watch_kosei_80" };
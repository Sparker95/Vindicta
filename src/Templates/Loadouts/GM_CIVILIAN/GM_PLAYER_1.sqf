removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

private _uniforms = [
	"gm_gc_civ_uniform_man_01_80_blk",
	"gm_gc_civ_uniform_man_01_80_blu",
	"gm_gc_civ_uniform_man_02_80_brn",
	"gm_ge_civ_uniform_blouse_80_gry",
	"gm_ge_ff_uniform_man_80_orn",
	"gm_ge_dbp_uniform_suit_80_blu"
];

//	==== Uniform ====
this forceAddUniform selectRandom _uniforms;
this addItemToUniform "ACE_Flashlight_Maglite_ML300L";

/* ==== Backpack ====
if (random 10 < 3) then {
	this addBackpack "gm_ge_backpack_satchel_80_blk";
};
*/

//	==== Weapons ====
private _gunsAndAmmo = [
	// pistols
	["gm_pm_blk", 		"gm_8Rnd_9x18mm_B_pst_pm_blk", 			true],	0.9,
	// flaregun
	["gm_lp1_blk",		"gm_1Rnd_265mm_flare_single_red_gc", 	true], 0.3,
	// smg
	["gm_mp2a1_blk", 	"gm_32Rnd_9x19mm_B_DM11_mp2_blk",		false], 0.1
];

(selectRandomWeighted _gunsAndAmmo) params ["_gun", "_ammo", "_isPistol"];
this addWeapon _gun;
if(_isPistol) then {
	this addHandgunItem _ammo;
} else {
	this addWeaponItem [_gun, _ammo];
};
for "_i" from 1 to 3 do {this addItemToUniform _ammo;};

//	==== Misc Items ====
this linkItem "ItemMap"; 			// Map
this linkItem "gm_watch_kosei_80"; 	// Watch
this linkItem "gm_ge_army_conat2";  // Compass

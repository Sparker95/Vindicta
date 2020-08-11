removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

//	==== Head Gear ====
this addHeadgear "gm_ge_headgear_sph4_oli";

//	==== Uniform ====
_RandomUniform = selectRandom ["gm_ge_army_uniform_pilot_oli", "gm_ge_army_uniform_pilot_oli", "gm_ge_pol_uniform_pilot_grn", "gm_ge_pol_uniform_pilot_rolled_grn"];
this forceAddUniform _RandomUniform;
this addItemToUniform "FirstAidKit";
this addItemToUniform "gm_ge_headgear_hat_80_oli";

//	==== Vest ====
_RandomVest = selectRandom ["gm_ge_army_vest_pilot_oli", "gm_ge_army_vest_pilot_pads_oli"];
this forceAddUniform _RandomVest;
this addItemToVest "gm_smokeshell_wht_dm25";
for "_i" from 1 to 2 do {this addItemToVest "gm_handgrenade_frag_dm51a1";}; // Frag Grenade

//	==== Weapons ====
private _guns = [
	["gm_mp2a1_blk",	"gm_30rnd_9x19mm_b_dm51_mp5a3_blk"], 0.5,
	["gm_mp5a3_blk",	"gm_30rnd_9x19mm_b_dm51_mp5a3_blk"], 0.5,
	["gm_mp5a2_blk",	"gm_30rnd_9x19mm_b_dm51_mp5a3_blk"], 0.5
];

(selectRandomWeighted _guns) params ["_gun", "_ammo"];
this addWeapon _gun;
this addPrimaryWeaponItem _ammo;
for "_i" from 1 to 3 do {this addItemToVest _ammo;};

//	==== Misc Items ====
this linkItem "ItemMap"; 			// Map
this linkItem "gm_watch_kosei_80"; 	// Watch
this linkItem "gm_ge_army_conat2"; 	// Compass
this linkitem "ItemRadio"; 			// Radio


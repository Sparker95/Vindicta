removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

//	==== Head Gear ====
this addHeadgear "gm_ge_headgear_hat_boonie_oli";

//	==== Uniform ====
this forceAddUniform "gm_ge_army_uniform_soldier_80_ols";
this addItemToUniform "FirstAidKit";
this addItemToUniform "gm_ge_facewear_m65";
this addItemToUniform "gm_ge_headgear_hat_80_oli";

//	==== Vest ====
this addVest "gm_ge_army_vest_80_rifleman";
for "_i" from 1 to 2 do {this addItemToVest "gm_smokeshell_wht_dm25";}; // Frag Grenade

//	==== Weapons ====
private _guns = [
	["gm_g3a4_oli"], 0.5,
	["gm_g3a4_blk"], 0.5,
	["gm_g3a4_grn"], 0.5,
	["gm_g3a4_des"], 0.1
];

(selectRandomWeighted _guns) params ["_gun"];
this addWeapon _gun;
this addPrimaryWeaponItem "gm_20Rnd_762x51mm_B_T_DM21_g3_blk";
for "_i" from 1 to 6 do {this addItemToVest "gm_20Rnd_762x51mm_B_T_DM21_g3_blk";};

this addWeapon "gm_lp1_blk";
this addHandgunItem "gm_1Rnd_265mm_flare_multi_red_DM23";
this addItemToVest	"gm_1Rnd_265mm_flare_multi_red_DM23";  	// Multi Red Flare
this addItemToVest 	"gm_1Rnd_265mm_flare_single_wht_DM15";  // White Flare
this addItemToVest 	"gm_1Rnd_265mm_flare_multi_yel_DM20";  	// Multi Yellow Flare
this addItemToVest 	"gm_1Rnd_265mm_flare_multi_grn_DM21";  	// Multi Green Flare

this AddWeapon "gm_ferod16_oli";

//	==== Misc Items ====
this linkItem "ItemMap"; 			// Map
this linkItem "gm_watch_kosei_80"; 	// Watch
this linkItem "gm_ge_army_conat2"; 	// Compass
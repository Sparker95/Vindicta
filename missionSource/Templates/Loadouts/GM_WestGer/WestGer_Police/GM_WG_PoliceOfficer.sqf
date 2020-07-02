removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

//	==== Head Gear ====
this addHeadgear "gm_ge_pol_headgear_cap_80_grn";

//	==== Uniform ====
this forceAddUniform "gm_ge_pol_uniform_suit_80_grn";
this addItemToUniform "FirstAidKit";

//	==== Weapons ====
private _gunAndAmmo = [
	["gm_mp2a1_blk", 	"gm_32Rnd_9x19mm_B_DM51_mp2_blk"		],	0.2,
	["gm_mpikms72_brn", "gm_30Rnd_762x39mm_B_57N231_ak47_blk"	],	0.8
];

(selectRandomWeighted _gunAndAmmo) params ["_gun", "_ammo"];
this addWeapon _gun;
this addPrimaryWeaponItem _ammo;
for "_i" from 1 to 2 do {this addItemToUniform _ammo;};

//	==== Misc Items ====
this linkItem "ItemMap"; 			// Map
this linkItem "gm_watch_kosei_80"; 	// Watch
this linkItem "gm_ge_army_conat2"; 	// Compass
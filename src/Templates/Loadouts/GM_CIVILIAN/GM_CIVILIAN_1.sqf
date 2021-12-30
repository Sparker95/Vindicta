removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

[this, selectRandom gVanillaFaces] call BIS_fnc_setIdentity;

this forceAddUniform selectRandom [
	"gm_gc_civ_uniform_man_01_80_blk",
	"gm_gc_civ_uniform_man_01_80_blu",
	"gm_gc_civ_uniform_man_02_80_brn",
	"gm_ge_civ_uniform_blouse_80_gry",
	"gm_gc_civ_uniform_man_03_80_blu", 
	"gm_gc_civ_uniform_man_03_80_grn", 
	"gm_gc_civ_uniform_man_03_80_gry", 
	"gm_gc_civ_uniform_man_04_80_blu", 
	"gm_gc_civ_uniform_man_04_80_gry"
];
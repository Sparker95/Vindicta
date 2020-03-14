removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

this forceAddUniform selectRandom [
	"gm_gc_civ_uniform_man_01_80_blk",
	"gm_gc_civ_uniform_man_01_80_blu",
	"gm_gc_civ_uniform_man_02_80_brn",
	"gm_ge_civ_uniform_blouse_80_gry"
];

[this, selectRandom gVanillaFaces, "ace_novoice"] call BIS_fnc_setIdentity;

this addBackpack selectRandom [
	"gm_ge_backpack_satchel_80_blk",
	"gm_ge_backpack_satchel_80_san"
];

this linkItem "ItemMap";
this linkItem "gm_watch_kosei_80";

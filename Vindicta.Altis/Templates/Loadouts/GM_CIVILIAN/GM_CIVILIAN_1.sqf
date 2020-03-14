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

if(random 5 < 2) then {
	this addGoggles selectRandomWeighted [
		"G_Squares", 			1
	];
};


if(random 10 > 5) then { this linkItem "gm_watch_kosei_80" };

[this, selectRandom gVanillaFaces, "ace_novoice"] call BIS_fnc_setIdentity;

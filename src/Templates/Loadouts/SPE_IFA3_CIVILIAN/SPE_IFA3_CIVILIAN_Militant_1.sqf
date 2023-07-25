removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

private _uniforms = [
	"U_SPE_CIV_Citizen_1",
	"U_SPE_CIV_Citizen_1_trop",
	"U_SPE_CIV_Citizen_1_tie",
	"U_SPE_CIV_Citizen_2",
	"U_SPE_CIV_Citizen_2_trop",
	"U_SPE_CIV_Citizen_2_tie",
	"U_SPE_CIV_Citizen_3",
	"U_SPE_CIV_Citizen_3_trop",
	"U_SPE_CIV_Citizen_3_tie",
	"U_SPE_CIV_Citizen_4",
	"U_SPE_CIV_Citizen_4_trop",
	"U_SPE_CIV_Citizen_4_tie",
	"U_SPE_CIV_Citizen_5",
	"U_SPE_CIV_Citizen_5_trop",
	"U_SPE_CIV_Citizen_5_tie",
	"U_SPE_CIV_Citizen_6",
	"U_SPE_CIV_Citizen_6_trop",
	"U_SPE_CIV_Citizen_6_tie",
	"U_SPE_CIV_Citizen_7",
	"U_SPE_CIV_Citizen_7_trop",
	"U_SPE_CIV_Citizen_7_tie",
	"U_SPE_CIV_Worker_1",
	"U_SPE_CIV_Worker_1_trop",
	"U_SPE_CIV_Worker_1_tie",
	"U_SPE_CIV_Worker_2",
    "U_SPE_CIV_Worker_2_trop",
    "U_SPE_CIV_Worker_2_tie",
    "U_SPE_CIV_Worker_3",
    "U_SPE_CIV_Worker_3_trop",
    "U_SPE_CIV_Worker_3_tie",
    "U_SPE_CIV_Worker_4",
    "U_SPE_CIV_Worker_4_trop",
    "U_SPE_CIV_Worker_4_tie",
    "U_SPE_CIV_Worker_Coverall_1",
    "U_SPE_CIV_Worker_Coverall_1_trop",
    "U_SPE_CIV_Worker_Coverall_2",
    "U_SPE_CIV_Worker_Coverall_2_trop",
    "U_SPE_CIV_Worker_Coverall_3",
    "U_SPE_CIV_Worker_Coverall_3_trop",
    "U_SPE_CIV_pak2_bruin",
    "U_SPE_CIV_pak2_bruin_tie",
    "U_SPE_CIV_pak2_bruin_swetr",
    "U_SPE_CIV_pak2_grijs",
    "U_SPE_CIV_pak2_grijs_tie",
    "U_SPE_CIV_pak2_grijs_swetr",
    "U_SPE_CIV_pak2_zwart",
    "U_SPE_CIV_pak2_zwart_alt",
    "U_SPE_CIV_pak2_zwart_tie",
    "U_SPE_CIV_pak2_zwart_tie_alt",
    "U_SPE_CIV_pak2_zwart_swetr",
    "U_SPE_CIV_Swetr_1",
    "U_SPE_CIV_Swetr_1_vest",
    "U_SPE_CIV_Swetr_2",
    "U_SPE_CIV_Swetr_2_vest",
    "U_SPE_CIV_Swetr_3",
    "U_SPE_CIV_Swetr_3_vest",
    "U_SPE_CIV_Swetr_4",
    "U_SPE_CIV_Swetr_4_vest",
    "U_SPE_CIV_Swetr_5",
    "U_SPE_CIV_Swetr_5_vest"
];

this forceAddUniform selectRandom _uniforms;

private _headgear = [
	"H_SPE_CIV_Worker_Cap_1",
    "H_SPE_CIV_Worker_Cap_2",
    "H_SPE_CIV_Worker_Cap_3",
    "H_SPE_CIV_Fedora_Cap_1",
    "H_SPE_CIV_Fedora_Cap_2",
    "H_SPE_CIV_Fedora_Cap_3",
    "H_SPE_CIV_Fedora_Cap_4",
    "H_SPE_CIV_Fedora_Cap_5",
    "H_SPE_CIV_Fedora_Cap_6"
];

if (random 10 < 1) then { this addVest selectRandom _vest;
};

private _gunsAndAmmo = [
	// pistols
	["SPE_P08", 						"SPE_8Rnd_9x19_P08", 		true],	2,
	["SPE_M1911", 						"SPE_7Rnd_45ACP_1911", 		true],	2,
    ["LIB_M1896", 						"LIB_10Rnd_9x19_M1896",     true],	2,
    ["LIB_M1895", 						"lib_7rnd_762x38", 		    true],	2,
    ["LIB_P38", 						"lib_8rnd_9x19", 		    true],	2,
    ["LIB_TT33", 						"lib_8rnd_762x25", 		    true],	2,
    ["LIB_WaltherPPK", 					"lib_7rnd_765x17_ppk", 		true],	2,
    ["LIB_Webley_mk6", 					"lib_6rnd_455", 		    true],	2,
    ["LIB_Welrod_mk1", 					"lib_6rnd_9x19_welrod", 	true],	2,
    // rifles
    ["LIB_DELISLE", 					"lib_7rnd_45acp_delisle", 	true],	1,
    // shotguns
    ["SPE_Fusil_Mle_208_12", 			"spe_2rnd_12x65_pellets", 	true],	1,
    ["SPE_Fusil_Mle_208_12_Sawedoff", 	"spe_2rnd_12x65_pellets", 	true],	1
];

(selectRandomWeighted _gunsAndAmmo) params ["_gun", "_ammo", "_isPistol"];

this addVest selectRandom ["V_BandollierB_blk", "V_BandollierB_cbr", "V_BandollierB_rgr", "V_BandollierB_khk", "V_BandollierB_oli"];

this addWeapon _gun;

if(_isPistol) then {
	this addHandgunItem _ammo;
} else {
	this addWeaponItem [_gun, _ammo];
};
//====Items====
for "_i" from 1 to 6 do { this addItemToUniform _ammo };

//====ACE Items====
this addItemToUniform "FirstAidKit";

//====Identity====
[this, ""] call BIS_fnc_setIdentity;
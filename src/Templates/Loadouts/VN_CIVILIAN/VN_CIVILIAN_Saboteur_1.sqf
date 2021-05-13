removeAllWeapons this;
removeAllItems this;
removeAllAssignedItems this;
removeUniform this;
removeVest this;
removeBackpack this;
removeHeadgear this;
removeGoggles this;

private _uniforms = [
	"vn_o_uniform_vc_01_01",
	"vn_o_uniform_vc_01_02",
	"vn_o_uniform_vc_01_04",
	"vn_o_uniform_vc_01_07",
	"vn_o_uniform_vc_01_06",
	"vn_o_uniform_vc_01_03",
	"vn_o_uniform_vc_01_05",
	"vn_o_uniform_vc_mf_01_07",
	"vn_o_uniform_vc_mf_10_07",
	"vn_o_uniform_vc_reg_11_08",
	"vn_o_uniform_vc_reg_11_09",
	"vn_o_uniform_vc_reg_11_10",
	"vn_o_uniform_vc_mf_11_07",
	"vn_o_uniform_vc_reg_12_08",
	"vn_o_uniform_vc_reg_12_09",
	"vn_o_uniform_vc_reg_12_10",
	"vn_o_uniform_vc_mf_12_07",
	"vn_o_uniform_vc_02_01",
	"vn_o_uniform_vc_02_02",
	"vn_o_uniform_vc_02_04",
	"vn_o_uniform_vc_02_07",
	"vn_o_uniform_vc_02_06",
	"vn_o_uniform_vc_02_03",
	"vn_o_uniform_vc_02_05",
	"vn_o_uniform_vc_mf_02_07",
    "vn_o_uniform_vc_03_01",
    "vn_o_uniform_vc_03_02",
    "vn_o_uniform_vc_03_04",
    "vn_o_uniform_vc_03_07",
    "vn_o_uniform_vc_03_06",
    "vn_o_uniform_vc_03_03",
    "vn_o_uniform_vc_03_05",
    "vn_o_uniform_vc_mf_03_07",
    "vn_o_uniform_vc_04_01",
    "vn_o_uniform_vc_04_02",
    "vn_o_uniform_vc_04_04",
    "vn_o_uniform_vc_04_07",
    "vn_o_uniform_vc_04_06",
    "vn_o_uniform_vc_04_03",
    "vn_o_uniform_vc_04_05",
    "vn_o_uniform_vc_mf_04_07",
    "vn_o_uniform_vc_05_01",
    "vn_o_uniform_vc_05_04",
    "vn_o_uniform_vc_05_03",
    "vn_o_uniform_vc_05_02",
    "vn_o_uniform_vc_mf_09_07"
];

this forceAddUniform selectRandom _uniforms;

private _headgear = [
	"H_Bandanna_blu",
    "H_Bandanna_camo",
    "H_Bandanna_cbr",
    "H_Bandanna_gry",
    "H_Bandanna_khk",
    "H_Bandanna_khk_hs",
    "H_Bandanna_mcamo",
    "H_Bandanna_sand",
    "H_Bandanna_sgg",
    "H_Bandanna_surfer",
    "H_Bandanna_surfer_blk",
    "H_Bandanna_surfer_grn",
    "H_Watchcap_blk",
    "H_Watchcap_cbr",
    "H_Watchcap_camo",
    "H_Watchcap_khk",
    "H_StrawHat",
    "H_StrawHat_dark",
    "H_Hat_Safari_olive_F",
    "H_Hat_Safari_sand_F",
    "vn_c_headband_04",
    "vn_b_headband_03",
    "vn_c_headband_03",
    "vn_c_headband_02",
    "vn_b_headband_01",
    "vn_c_headband_01",
    "vn_c_conehat_01",
    "vn_c_conehat_02",
    "vn_b_bandana_03",
    "vn_b_bandana_01",
    "vn_o_boonie_vc_01_01"
];

if (random 10 < 1) then { this addVest selectRandom _vest;
};

if(random 5 < 1) then {
	this addGoggles selectRandomWeighted [
	/*"vn_o_bandana_b",   0,
    "vn_o_bandana_g",   0,*/
    "vn_o_scarf_01_04",   1,
    "vn_b_scarf_01_03",   1,
    "vn_o_scarf_01_03",   1,
    "vn_o_scarf_01_02",   1,
    "vn_b_scarf_01_01",   1,
    "vn_o_scarf_01_01",   1
	];
};

this addBackpack selectRandom [
	"vn_c_pack_01",
    "vn_c_pack_01_medic_pl",
    "vn_c_pack_01_engineer_pl",
    "vn_c_pack_02"
];

//====Items====
for "_i" from 1 to 3 do { this addItemToUniform _ammo };

//====ACE Items====
this addItemToUniform "FirstAidKit";
/*for "_i" from 1 to 2 do {this addItemToUniform "ACE_fieldDressing";};
this addItemToUniform "ACE_elasticBandage";
this addItemToUniform "ACE_packingBandage";
this addItemToUniform "ACE_quikclot";*/

//====Identity====

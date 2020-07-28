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
	"U_C_E_LooterJacket_01_F",
	"U_C_Man_casual_1_F",
	"U_C_Man_casual_2_F",
	"U_C_Man_casual_3_F",
	"U_C_Man_casual_4_F",
	"U_C_Man_casual_5_F",
	"U_C_Man_casual_6_F",
	"U_C_man_sport_2_F",
	"U_C_Mechanic_01_F",
	"U_C_Poloshirt_burgundy",
	"U_C_Poloshirt_redwhite",
	"U_C_Poloshirt_salmon",
	"U_C_Poloshirt_stripped",
	"U_C_Poloshirt_tricolour",
	"U_C_Uniform_Farmer_01_F",
	"U_I_C_Soldier_Bandit_3_F",
	"U_I_C_Soldier_Bandit_5_F",
	"U_I_L_Uniform_01_tshirt_black_F",
	"U_I_L_Uniform_01_tshirt_skull_F",
	"U_I_L_Uniform_01_tshirt_sport_F",
	"U_O_R_Gorka_01_black_F",
    "U_C_Commoner_shorts",
    "U_C_HunterBody_grn",
    "U_C_IDAP_Man_TeeShorts_F",
    "U_C_Man_casual_1_F",
    "U_C_Man_casual_2_F",
    "U_C_Man_casual_3_F",
    "U_C_Man_casual_4_F",
    "U_C_Man_casual_5_F",
    "U_C_Man_casual_6_F",
    "U_C_man_sport_1_F",
    "U_C_man_sport_2_F",
    "U_C_man_sport_3_F",
    "U_C_Mechanic_01_F",
    "U_C_Poloshirt_blue",
    "U_C_Poloshirt_burgundy",
    "U_C_Poloshirt_redwhite",
    "U_C_Poloshirt_salmon",
    "U_C_Poloshirt_stripped",
    "U_C_Poloshirt_tricolour",
    "U_C_Poor_1",
    "U_C_Poor_2",
    "U_C_TeeSurfer_shorts_1",
    "U_C_TeeSurfer_shorts_2",
    "U_C_WorkerCoveralls"
];

this forceAddUniform selectRandom _uniforms;

private _vest = [
	"V_Pocketed_black_F",
	"V_Pocketed_coyote_F",
	"V_Pocketed_olive_F"
];

if (random 10 < 1) then { this addVest selectRandom _vest;
};

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
    "H_Cap_blk",
    "H_Cap_blk_CMMG",
    "H_Cap_blk_ION",
    "H_Cap_blk_Syndikat_F",
    "H_Cap_blu",
    "H_Cap_grn",
    "H_Cap_grn_BI",
    "H_Cap_grn_Syndikat_F",
    "H_Cap_khaki_specops_UK",
    "H_Cap_oli",
    "H_Cap_oli_Syndikat_F",
    "H_Cap_Orange_IDAP_F",
    "H_Cap_press",
    "H_Cap_red",
    "H_Cap_surfer",
    "H_Cap_tan",
    "H_Cap_tan_Syndikat_F",
    "H_Cap_usblack",
	"H_HeadBandage_bloody_F",
    "H_HeadBandage_clean_F",
    "H_HeadBandage_stained_F",
	"H_StrawHat",
    "H_StrawHat_dark",
    "H_Hat_Safari_olive_F",
    "H_Hat_Safari_sand_F"
];

if (random 5 < 1) then { this addHeadgear selectRandom _headgear;
};

this addBackpack selectRandom [
	"B_Messenger_Black_F",
    "B_Messenger_Gray_F",
    "B_Messenger_Coyote_F",
    "B_Messenger_Olive_F",
	"B_FieldPack_blk",
    "B_FieldPack_cbr",
    "B_FieldPack_oli",
    "B_AssaultPack_blk",
    "B_AssaultPack_cbr",
    "B_Carryall_cbr"
];

//====Items====
this linkItem "ItemMap";
this linkItem "ItemCompass";
this linkItem "ItemWatch";

//====ACE Items====
for "_i" from 1 to 3 do {this addItemToUniform "ACE_fieldDressing";};
this addItemToUniform "ACE_elasticBandage";
for "_i" from 1 to 2 do {this addItemToUniform "ACE_packingBandage";};
this addItemToUniform "ACE_tourniquet";

//====Identity====
private _voice = [
	"male01gre",
    "male02gre",
    "male03gre",
	"male04gre",
	"male05gre",
	"male06gre",
	"male01engfre",
	"male02engfre",
	"male01eng",
	"male02eng",
	"male03eng",
	"male04eng",
	"male05eng",
	"male06eng",
	"male07eng",
	"male08eng",
	"male09eng",
	"male10eng",
	"male11eng",
	"male12eng",
	"male01engb",
	"male02engb",
	"male03engb",
	"male04engb",
	"male05engb"
];

[this, selectRandom gVanillaFaces,selectRandom _voice] call BIS_fnc_setIdentity;
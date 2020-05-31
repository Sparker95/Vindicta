
// ██████╗██╗██╗   ██╗██╗██╗     ██╗ █████╗ ███╗   ██╗
//██╔════╝██║██║   ██║██║██║     ██║██╔══██╗████╗  ██║
//██║     ██║██║   ██║██║██║     ██║███████║██╔██╗ ██║
//██║     ██║╚██╗ ██╔╝██║██║     ██║██╔══██║██║╚██╗██║
//╚██████╗██║ ╚████╔╝ ██║███████╗██║██║  ██║██║ ╚████║
// ╚═════╝╚═╝  ╚═══╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝
//http://patorjk.com/software/taag/#p=display&v=3&f=ANSI%20Shadow&t=Civilian

//Updated: March 2020 by Marvis

_array = [];

_array set [T_SIZE-1, nil]; //Make an array having the size equal to the number of categories first

_array set [T_NAME, "tCivilian"];                           //Template name + variable (not displayed)
_array set [T_DESCRIPTION, "Vanilla Altis civilians."];     //Template display description
_array set [T_DISPLAY_NAME, "Arma 3 Altis Civilians"];      //Template display name
_array set [T_FACTION, T_FACTION_Civ];                      //Faction type
_array set [T_REQUIRED_ADDONS, ["A3_Characters_F"]];        //Addons required to play this template

//==== Arsenal ====
_arsenal = [];
_arsenal resize T_ARSENAL_SIZE;
_arsenal set[T_ARSENAL_primary, []];
_arsenal set[T_ARSENAL_primary_items, []];
_arsenal set[T_ARSENAL_secondary, []];
_arsenal set[T_ARSENAL_secondary_items, []];
_arsenal set[T_ARSENAL_handgun, []];
_arsenal set[T_ARSENAL_handgun_items, []];
_arsenal set[T_ARSENAL_ammo, []];
_arsenal set[T_ARSENAL_items, [
    "ACE_Flashlight_Maglite_ML300L",
    "ACE_HandFlare_White"
]];
_arsenal set[T_ARSENAL_vests, []];
_arsenal set[T_ARSENAL_backpacks, [
    "ACE_TacticalLadder_Pack",
    "B_Messenger_Black_F",
    "B_Messenger_Coyote_F",
    "B_Messenger_Olive_F"
]];
_arsenal set[T_ARSENAL_uniforms, [
    "U_BG_Guerilla2_1",
    "U_BG_Guerilla2_2",
    "U_BG_Guerilla2_3",
    "U_BG_Guerilla3_1",
    "U_BG_Guerilla3_2",
    "U_C_Commoner_shorts",
    "U_C_ConstructionCoverall_Black_F",
    "U_C_ConstructionCoverall_Blue_F",
    "U_C_Driver_1",
    "U_C_Journalist",
    "U_C_Man_casual_1_F",
    "U_C_Man_casual_2_F",
    "U_C_man_sport_1_F",
    "U_C_Mechanic_01_F",
    "U_C_Paramedic_01_F",
    "U_C_Poloshirt_blue",
    "U_C_Poor_1",
    "U_C_Scientist",
    "U_C_TeeSurfer_shorts_1",
    "U_C_WorkerCoveralls",
    "U_Competitor",
    "U_I_C_Soldier_Bandit_1_F",
    "U_I_C_Soldier_Bandit_2_F",
    "U_I_C_Soldier_Bandit_3_F",
    "U_I_C_Soldier_Bandit_4_F",
    "U_I_C_Soldier_Bandit_5_F",
    "U_IG_Guerilla2_1",
    "U_IG_Guerilla2_2",
    "U_IG_Guerilla2_3",
    "U_IG_Guerilla3_1",
    "U_IG_Guerilla3_2",
    "U_BG_Guerrilla_6_1",
    "U_I_C_Soldier_Para_4_F",
    "U_I_L_Uniform_01_camo_F",
    "U_I_L_Uniform_01_deserter_F",
    "U_I_G_resistanceLeader_F",
    "U_BG_Guerilla1_1",
    "U_I_C_Soldier_Para_3_F",
    "U_Marshal",
    "U_OG_Guerilla2_1",
    "U_OG_Guerilla2_2",
    "U_OG_Guerilla2_3",
    "U_OG_Guerilla3_1",
    "U_OG_Guerilla3_2",
    "U_C_HunterBody_grn",
    "U_OrestesBody",
    "U_Rangemaster",
    "U_BG_leader",

    // CONTACT DLC 
    "U_I_L_Uniform_01_tshirt_black_F",
    "U_C_Uniform_Scientist_01_F",
    "U_C_Uniform_Scientist_01_formal_F",
    "U_O_R_Gorka_01_black_F",
    "U_C_E_LooterJacket_01_F"
]];
_arsenal set[T_ARSENAL_facewear, [
    //"G_Aviator", mwuhahaha
    "G_Balaclava_blk",
    "G_Balaclava_oli",
    "G_Bandanna_blk",
    "G_Bandanna_khk",
    "G_RegulatorMask_F",
    "G_Lady_Mirror",
    "G_Lowprofile",
    "G_Shades_Black",
    "G_Spectacles",
    "G_Spectacles_Tinted",
    "G_Sport_Blackred",
    "G_Sport_Red",
    "G_Squares",
    "G_Squares_Tinted",
    "G_Tactical_Black",
    "G_Tactical_Clear"
]];
_arsenal set[T_ARSENAL_headgear, [
    "H_Shemag_olive",
    "H_ShemagOpen_tan",
    "H_ShemagOpen_khk",
    "H_Hat_Tinfoil_F",
    "H_Bandanna_blu",
    "H_Bandanna_gry",
    "H_Watchcap_blk",
    "H_Booniehat_grn",
    "H_Booniehat_tan",
    "H_Cap_blk",
    "H_Cap_red",
    "H_Construction_basic_black_F",
    "H_Construction_basic_orange_F",
    "H_HeadBandage_bloody_F",
    "H_HeadBandage_stained_F",
    "H_Helmet_Skate",
    "H_StrawHat"
]];

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf = _inf apply { ["Arma3_CIVILIAN_Default"] };
_inf set [T_INF_default, ["I_L_Looter_SG_F"]];
_inf set [T_INF_rifleman, [
    "Arma3_PLAYER_1"
]];
_inf set [T_INF_unarmed, [
    "Arma3_CIVILIAN_1"
]];
_inf set [T_INF_exp, [
    "Arma3_CIVILIAN_Saboteur_1"
]];
_inf set [T_INF_survivor, [
    "Arma3_CIVILIAN_Militant_1"
]];

//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh resize T_VEH_SIZE;
_veh set [T_VEH_default, [
    "C_Hatchback_01_sport_F",   5,
    "C_Hatchback_01_F",         20,
    "C_Truck_02_box_F",         3,
    "C_Truck_02_fuel_F",        0,
    "C_Offroad_02_unarmed_F",   10,
    "C_Van_01_fuel_F",          0,
    "C_Truck_02_transport_F",   3,
    "C_Truck_02_covered_F",     3,
    "C_Offroad_01_F",           5,
    "C_Offroad_01_repair_F",    0,
    "C_Quadbike_01_F",          1,
    "C_SUV_01_F",               3,
    "C_Van_01_transport_F",     1,
    "C_Van_02_medevac_F",       1,
    "C_Van_02_vehicle_F",       1,
    "C_Van_02_service_F",       1,
    "C_Van_02_transport_F",     1
]];

//==== Cargo ====
_cargo = +(tDefault select T_CARGO);

// ==== Inventory ====
_inv = [T_INV] call t_fnc_newCategory;
_inv set [T_INV_items, +t_miscItems_civ_modern ];
_inv set [T_INV_backpacks, ["B_AssaultPack_cbr", "B_Carryall_ocamo", "B_Carryall_oucamo"]];

//==== Arrays ====
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, []];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, []];
_array set [T_ARSENAL, _arsenal];
_array set [T_INV, _inv];

_array
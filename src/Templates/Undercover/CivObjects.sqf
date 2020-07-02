#ifndef _SQF_VM
if(!isServer) exitWith {};
#else
if(true) exitWith {};
#endif

/*
----------------------------------------------------------------------------------------------
							LIST OF "CIVILIAN" GEAR AND VEHICLES
----------------------------------------------------------------------------------------------
*/



/* 
----------------------------------------------------------------------------------------------
	CIVILIAN CLOTHING
----------------------------------------------------------------------------------------------
*/

g_UM_civUniforms = [
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
	"U_C_Uniform_Scientist_01_F",
	"U_C_Uniform_Scientist_01_formal_F",
	"U_C_Uniform_Scientist_02_formal_F",
	"U_I_C_Soldier_Bandit_3_F",
	"U_I_C_Soldier_Bandit_5_F",
	"U_I_L_Uniform_01_tshirt_black_F",
	"U_I_L_Uniform_01_tshirt_skull_F",
	"U_I_L_Uniform_01_tshirt_sport_F",
	"U_Marshal",
	"U_O_R_Gorka_01_black_F",
    "U_C_Commoner_shorts",
    "U_C_ConstructionCoverall_Black_F",
    "U_C_ConstructionCoverall_Blue_F",
    "U_C_ConstructionCoverall_Red_F",
    "U_C_ConstructionCoverall_Vrana_F",
    "U_C_Driver_1_black",
    "U_C_Driver_1_blue",
    "U_C_Driver_1_green",
    "U_C_Driver_1_orange",
    "U_C_Driver_1_red",
    "U_C_Driver_1_white",
    "U_C_Driver_1_yellow",
    "U_C_Driver_1",
    "U_C_Driver_2",
    "U_C_Driver_3",
    "U_C_Driver_4",
    "U_C_HunterBody_grn",
    "U_C_IDAP_Man_cargo_F",
    "U_C_IDAP_Man_casual_F",
    "U_C_IDAP_Man_Jeans_F",
    "U_C_IDAP_Man_shorts_F",
    "U_C_IDAP_Man_Tee_F",
    "U_C_IDAP_Man_TeeShorts_F",
    "U_C_Journalist",
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
    "U_C_Paramedic_01_F",
    "U_C_Poloshirt_blue",
    "U_C_Poloshirt_burgundy",
    "U_C_Poloshirt_redwhite",
    "U_C_Poloshirt_salmon",
    "U_C_Poloshirt_stripped",
    "U_C_Poloshirt_tricolour",
    "U_C_Poor_1",
    "U_C_Poor_2",
    "U_C_Scientist",
    "U_C_TeeSurfer_shorts_1",
    "U_C_TeeSurfer_shorts_2",
    "U_C_WorkerCoveralls",
    "U_Competitor",
    "U_I_C_Soldier_Bandit_1_F",
    "U_I_C_Soldier_Bandit_2_F",
    "U_I_C_Soldier_Bandit_3_F",
    "U_I_C_Soldier_Bandit_4_F",
    "U_I_C_Soldier_Bandit_5_F",
    "U_Marshal",
    "U_OrestesBody",
    "U_Rangemaster",

    // CONTACT DLC 
    "U_I_L_Uniform_01_tshirt_black_F",
    "U_I_L_Uniform_01_tshirt_olive_F",
    "U_I_L_Uniform_01_tshirt_skull_F",
    "U_I_L_Uniform_01_tshirt_sport_F",
    "U_C_Uniform_Scientist_01_F",
    "U_C_Uniform_Scientist_02_F",
    "U_C_Uniform_Scientist_01_formal_F",
    "U_C_Uniform_Scientist_02_formal_F",
    "U_O_R_Gorka_01_black_F",
    "U_C_E_LooterJacket_01_F"
];
publicVariable "g_UM_civUniforms";

g_UM_civHeadgear = [
    "H_Hat_Tinfoil_F",
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
    "H_Booniehat_dirty",
    "H_Booniehat_grn",
    "H_Booniehat_khk_hs",
    "H_Booniehat_oli",
    "H_Booniehat_tan",
    "H_Cap_Black_IDAP_F",
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
    "H_Cap_White_IDAP_F",
    "H_Construction_basic_black_F",
    "H_Construction_basic_orange_F",
    "H_Construction_basic_red_F",
    "H_Construction_basic_vrana_F",
    "H_Construction_basic_white_F",
    "H_Construction_basic_yellow_F",
    "H_Construction_earprot_black_F",
    "H_Construction_earprot_orange_F",
    "H_Construction_earprot_red_F",
    "H_Construction_earprot_vrana_F",
    "H_Construction_earprot_white_F",
    "H_Construction_earprot_yellow_F",
    "H_Construction_headset_black_F",
    "H_Construction_headset_orange_F",
    "H_Construction_headset_red_F",
    "H_Construction_headset_vrana_F",
    "H_Construction_headset_white_F",
    "H_Construction_headset_yellow_F",
    "H_EarProtectors_black_F",
    "H_EarProtectors_orange_F",
    "H_EarProtectors_red_F",
    "H_EarProtectors_white_F",
    "H_EarProtectors_yellow_F",
    "H_HeadBandage_bloody_F",
    "H_HeadBandage_clean_F",
    "H_HeadBandage_stained_F",
    "H_HeadSet_black_F",
    "H_HeadSet_orange_F",
    "H_HeadSet_red_F",
    "H_HeadSet_white_F",
    "H_HeadSet_yellow_F",
    "H_Helmet_Skate",
    "H_RacingHelmet_1_black_F",
    "H_RacingHelmet_1_blue_F",
    "H_RacingHelmet_1_F",
    "H_RacingHelmet_1_green_F",
    "H_RacingHelmet_1_orange_F",
    "H_RacingHelmet_1_red_F",
    "H_RacingHelmet_1_white_F",
    "H_RacingHelmet_1_yellow_F",
    "H_RacingHelmet_2_F",
    "H_RacingHelmet_3_F",
    "H_RacingHelmet_4_F",
    "H_StrawHat",
    "H_StrawHat_dark"
];
publicVariable "g_UM_civHeadgear";

g_UM_civVests = [
    "V_DeckCrew_blue_F",
    "V_DeckCrew_brown_F",
    "V_DeckCrew_green_F",
    "V_DeckCrew_red_F",
    "V_DeckCrew_violet_F",
    "V_DeckCrew_white_F",
    "V_DeckCrew_yellow_F",
    "V_Plain_crystal_F",
    "V_Plain_medical_F",
    "V_Pocketed_black_F",
    "V_Pocketed_coyote_F",
    "V_Pocketed_olive_F",
    "V_Safety_blue_F",
    "V_Safety_orange_F",
    "V_Safety_yellow_F"
];
publicVariable "g_UM_civVests";

g_UM_civFacewear = [
    "G_Aviator",
    "G_Combat",
    "G_Combat_Goggles_tna_F",
    "G_EyeProtectors_Earpiece_F",
    "G_EyeProtectors_F",
    "G_Lady_Blue",
    "G_Lady_Dark",
    "G_Lady_Mirror",
    "G_Lady_Red",
    "G_Lowprofile",
    "G_Respirator_blue_F",
    "G_Respirator_white_F",
    "G_Respirator_yellow_F",
    "G_Shades_Black",
    "G_Shades_Blue",
    "G_Shades_Green",
    "G_Shades_Red",
    "G_Spectacles",
    "G_Spectacles_Tinted",
    "G_Sport_Blackred",
    "G_Sport_BlackWhite",
    "G_Sport_Blackyellow",
    "G_Sport_Checkered",
    "G_Sport_Greenblack",
    "G_Sport_Red",
    "G_Squares",
    "G_Squares_Tinted",
    "G_Tactical_Black",
    "G_Tactical_Clear"
];
publicVariable "g_UM_civFacewear";

g_UM_civBackpacks = [
    "ACE_TacticalLadder_Pack",
	"B_Messenger_Black_F",
    "B_Messenger_Coyote_F",
    "B_Messenger_Olive_F"
];
publicVariable "g_UM_civBackpacks";

g_UM_ghillies = [
	"U_B_FullGhillie_ard",
    "U_B_FullGhillie_lsh",
    "U_B_FullGhillie_sard",
    "U_B_GhillieSuit",
    "U_B_T_FullGhillie_tna_F",
    "U_I_FullGhillie_ard",
    "U_I_FullGhillie_lsh",
    "U_I_FullGhillie_sard",
    "U_I_GhillieSuit",
    "U_O_FullGhillie_ard",
    "U_O_FullGhillie_lsh",
    "U_O_FullGhillie_sard",
    "U_O_GhillieSuit",
    "U_O_T_FullGhillie_tna_F"
];
publicVariable "g_UM_ghillies";

/* 
----------------------------------------------------------------------------------------------
	ITEMS
----------------------------------------------------------------------------------------------
*/

g_UM_civItems = [
	"ItemWatch",
	"Toolkit",
	"Medikit",
	"FirstAidKit"
];
publicVariable "g_UM_civItems";

// Exceptions for certain "dummy weapons" used in some innocent animations
g_UM_civWeapons = [
    "ACE_FakePrimaryWeapon",
    "Rifle_Base_F",
    "CarHorn",
    "TruckHorn",
    "Binocular",
    "Rangefinder",
    "Laserdesignator",
    "Laserdesignator_02",
    "Laserdesignator_03",
    "ACE_Flashlight_Maglite_ML300L",
    ""
];
publicVariable "g_UM_civWeapons";

g_UM_suspWeapons = [
    "Binocular",
    "Rangefinder",
    "Laserdesignator",
    "Laserdesignator_02",
    "ACE_Flashlight_Maglite_ML300L",
    "Laserdesignator_03"
];
publicVariable "g_UM_suspWeapons";

/* 
----------------------------------------------------------------------------------------------
	VEHICLES
----------------------------------------------------------------------------------------------
*/

// no longer used array of civilian vehicles 

g_UM_civVehs = [
    "C_Hatchback_01_sport_F",
    "C_Hatchback_01_F",
    "C_Truck_02_box_F",
    "C_Truck_02_fuel_F",
    "C_Offroad_02_unarmed_F",
    "C_Van_01_fuel_F",
    "C_Truck_02_transport_F",
    "C_Truck_02_covered_F",
    "C_Kart_01_F",
    "C_Kart_01_Blu_F",
    "C_Kart_01_Fuel_F",
    "C_Kart_01_Red_F",
    "C_Kart_01_Vrana_F",
    "C_Offroad_01_F",
    "C_Offroad_01_repair_F",
    "C_Quadbike_01_F",
    "C_SUV_01_F",
    "C_Van_01_transport_F",
    "C_Van_02_medevac_F",
    "C_Van_02_vehicle_F",
    "C_Van_02_service_F",
    "C_Van_02_transport_F",
    "C_IDAP_Offroad_02_unarmed_F",
    "C_IDAP_Offroad_01_F",
    "C_IDAP_Van_02_medevac_F",
    "C_IDAP_Van_02_vehicle_F",
    "C_IDAP_Van_02_transport_F",
    "C_IDAP_Truck_02_transport_F",
    "C_IDAP_Truck_02_F",
    "C_IDAP_Truck_02_water_F",
    "C_Boat_Civil_01_F",
    "C_Boat_Civil_01_rescue_F",
    "C_Rubberboat",
    "C_Boat_Transport_02_F",
    "C_Scooter_Transport_01_F",
    "I_C_Van_02_transport_F",
    "I_C_Van_02_vehicle_F"
];
publicVariable "g_UM_civVehs";

/*
CUP Takistani Army
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tCUP_TKA"];
_array set [T_DESCRIPTION, "Takistani Army. uses CUP. Made by MacTheGoon"];
_array set [T_DISPLAY_NAME, "CUP Takistani Army"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, [
	"CUP_Creatures_Military_Taki",	// CUP Units
	"CUP_Weapons_WeaponsCore",		// CUP Weapons
	"CUP_Vehicles_Core",			// CUP Vehicles
	"rhs_c_troops",					// RHSAFRF
	"rhsgref_c_troops",				// RHSGREF
	"rhsusf_c_troops"				// RHSUSAF
]];

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default, ["CUP_O_TK_Soldier_Backpack"]];

_inf set [T_INF_SL, ["CUP_O_TK_Soldier_SL"]];
_inf set [T_INF_TL, ["CUP_O_TK_Soldier_SL"]];
_inf set [T_INF_officer, ["CUP_O_TK_Story_Aziz"]];
_inf set [T_INF_GL, ["CUP_O_TK_Soldier_GL"]];
_inf set [T_INF_rifleman, ["CUP_O_TK_Soldier_Backpack"]];
_inf set [T_INF_marksman, ["CUP_O_TK_Sniper"]];
_inf set [T_INF_sniper, ["CUP_O_TK_Sniper_KSVK"]];
_inf set [T_INF_spotter, ["CUP_O_TK_Spotter"]];
_inf set [T_INF_exp, ["CUP_O_sla_Engineer"]];
_inf set [T_INF_ammo, ["RHS_LDF_MG_2", "RHS_LDF_AT_2"]];
_inf set [T_INF_LAT, ["CUP_O_TK_Soldier_AT"]];
_inf set [T_INF_AT, ["CUP_O_TK_Soldier_HAT"]];
_inf set [T_INF_AA, ["CUP_O_TK_Soldier_AA"]];
_inf set [T_INF_LMG, ["CUP_O_TK_Soldier_AR"]];
_inf set [T_INF_HMG, ["CUP_O_TK_Soldier_MG"]];
_inf set [T_INF_medic, ["CUP_O_TK_Medic"]];
_inf set [T_INF_engineer, ["CUP_O_TK_Engineer"]];
_inf set [T_INF_crew, ["CUP_O_TK_Crew"]];
_inf set [T_INF_crew_heli, ["CUP_O_TK_Pilot"]];
_inf set [T_INF_pilot, ["CUP_O_TK_Pilot"]];
_inf set [T_INF_pilot_heli, ["CUP_O_TK_Pilot"]];
//_inf set [T_INF_survivor, ["CUP_O_sla_Soldier"]];
//_inf set [T_INF_unarmed, ["CUP_O_sla_Soldier"]];

// Recon
_inf set [T_INF_recon_TL, ["CUP_O_TK_SpecOps_TL"]];
_inf set [T_INF_recon_rifleman, ["CUP_O_TK_SpecOps"]];
_inf set [T_INF_recon_medic, ["CUP_O_TK_Medic"]];
_inf set [T_INF_recon_exp, ["CUP_O_TK_Soldier_Backpack"]];
_inf set [T_INF_recon_LAT, ["CUP_O_TK_Soldier_AT"]];
_inf set [T_INF_recon_marksman, ["CUP_O_TK_Sniper_KSVK"]];
_inf set [T_INF_recon_JTAC, ["CUP_O_TK_SpecOps"]];


// Divers, still vanilla
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];



//==== Vehicles ====
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["CUP_O_LR_MG_TKM"]];

_veh set [T_VEH_car_unarmed, ["CUP_O_LR_Transport_TKA","CUP_O_UAZ_Open_TKA"]];
_veh set [T_VEH_car_armed, ["CUP_O_LR_MG_TKA","CUP_O_LR_SPG9_TKA","CUP_O_UAZ_METIS_TKA","CUP_O_UAZ_MG_TKA","CUP_O_UAZ_AGS30_TKA","CUP_O_UAZ_SPG9_TKA"]];

_veh set [T_VEH_MRAP_unarmed, ["CUP_O_MTLB_pk_TKA"]];
_veh set [T_VEH_MRAP_HMG, ["CUP_O_LR_MG_TKA", "CUP_O_BMP1P_TKA"]];
_veh set [T_VEH_MRAP_GMG, ["CUP_O_BMP2_TKA"]];

_veh set [T_VEH_IFV, ["CUP_O_BMP1_TKA", "CUP_O_BMP1P_TKA", "CUP_O_BMP2_TKA", "CUP_O_BMP2_ZU_TKA"]];
_veh set [T_VEH_APC, ["CUP_O_M113_TKA", "CUP_O_BMP2_TKA"]];
_veh set [T_VEH_MBT, ["CUP_O_T34_TKA", "CUP_O_T55_TK", "CUP_O_T72_TKA"]];
_veh set [T_VEH_MRLS, ["CUP_O_BM21_TKA"]];
_veh set [T_VEH_SPA, ["rhsgref_cdf_2s1"]];
_veh set [T_VEH_SPAA, ["CUP_O_ZSU23_Afghan_TK","CUP_O_Ural_ZU23_TKA"]];

_veh set [T_VEH_stat_HMG_high, ["CUP_O_KORD_high_TK"]];
//_veh set [T_VEH_stat_GMG_high, [""]];
_veh set [T_VEH_stat_HMG_low, ["CUP_O_KORD_TK", "rhsgref_nat_DSHKM_Mini_TriPod"]];
_veh set [T_VEH_stat_GMG_low, ["CUP_O_AGS_TK"]];
_veh set [T_VEH_stat_AA, ["CUP_O_Igla_AA_pod_TK", "CUP_O_ZU23_TK"]];
_veh set [T_VEH_stat_AT, ["rhs_Kornet_9M133_2_msv", "rhs_Metis_9k115_2_msv", "rhsgref_cdf_SPG9M", "rhsgref_cdf_SPG9"]];

_veh set [T_VEH_stat_mortar_light, ["CUP_O_2b14_82mm_TK"]];
_veh set [T_VEH_stat_mortar_heavy, ["rhs_D30_msv"]];

_veh set [T_VEH_heli_light, ["CUP_O_UH1H_TKA"]];
_veh set [T_VEH_heli_heavy, ["CUP_O_Mi17_TK"]];
//_veh set [T_VEH_heli_cargo, [""]];
_veh set [T_VEH_heli_attack, ["CUP_O_Mi24_D_Dynamic_TK", "CUP_O_UH1H_armed_TKA","CUP_O_UH1H_gunship_SLA_TKA"]];

_veh set [T_VEH_plane_attack, ["CUP_O_Su25_Dyn_TKA", "CUP_O_Su25_Dyn_TKA"]];
_veh set [T_VEH_plane_fighter, ["CUP_O_L39_TK"]];
//_veh set [T_VEH_plane_cargo, [""]];
_veh set [T_VEH_plane_unarmed, ["RHS_AN2"]];
//_veh set [T_VEH_plane_VTOL, [""]];

_veh set [T_VEH_boat_unarmed, ["B_Boat_Transport_01_F", "I_C_Boat_Transport_02_F"]];
//_veh set [T_VEH_boat_armed, [""]];

_veh set [T_VEH_personal, ["B_Quadbike_01_F"]];

_veh set [T_VEH_truck_inf, ["CUP_O_Ural_TKA", "rhsgref_cdf_zil131_open", "rhsgref_cdf_gaz66", "rhsgref_cdf_gaz66o"]];
_veh set [T_VEH_truck_cargo, ["CUP_O_V3S_Open_TKA","CUP_O_V3S_Covered_TKA","CUP_O_Ural_Open_TKA","CUP_O_Ural_TKA"]];
_veh set [T_VEH_truck_ammo, ["CUP_O_Ural_Reammo_TKA"]];
_veh set [T_VEH_truck_repair, ["CUP_O_Ural_Repair_TKA"]];
_veh set [T_VEH_truck_medical , ["CUP_O_LR_Ambulance_TKA"]];
_veh set [T_VEH_truck_fuel, ["CUP_O_Ural_Refuel_TKA"]];

//_veh set [T_VEH_submarine, ["B_SDV_01_F"]];

//==== Drones ====
_drone = []; _drone resize T_DRONE_SIZE;
_drone set [T_DRONE_SIZE-1, nil];
_drone set [T_DRONE_DEFAULT, ["rhs_pchela1t_vvsc"]];


//_drone set [T_DRONE_UGV_unarmed, ["B_UGV_01_F"]];
//_drone set [T_DRONE_UGV_armed, ["B_UGV_01_rcws_F"]];
//_drone set [T_DRONE_plane_attack, ["B_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_plane_unarmed, ["B_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_heli_attack, ["B_T_UAV_03_dynamicLoadout_F"]];
//_drone set [T_DRONE_quadcopter, ["B_UAV_01_F"]];
//_drone set [T_DRONE_designator, ["B_Static_Designator_01_F"]];
//_drone set [T_DRONE_stat_HMG_low, ["B_HMG_01_A_F"]];
//_drone set [T_DRONE_stat_GMG_low, ["B_GMG_01_A_F"]];
//_drone set [T_DRONE_stat_AA, ["B_SAM_System_03_F"]];

//==== Cargo ====
_cargo = +(tDefault select T_CARGO);

//==== Groups ====
_group = +(tDefault select T_GROUP);


//==== Set arrays ====
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];

_array // End template

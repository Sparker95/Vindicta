_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tDAF"];
_array set [T_DESCRIPTION, "Dutch Armed Forces Tan. Made possible by a dutchman."];
_array set [T_DISPLAY_NAME, "Dutch Armed Forces - Tan"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, [
	"CUP_Weapons_M1014", //CUP Weapons
	"CUP_wheeledvehicles_Octaiva", //CUP Vehicles
	"CUP_Creatures_Military_USArmy", //CUP Units
	"FIR_Baseplate", //FIR AWS
	"C7NLD", //Colt C7NLD/C8NLD Weapons
	"bma3_bushmaster", //Bushmaster
	"NLD_Units_Main", //NLD Units (Main addon, contains all dependencies if you sub it.)
	"FIR_F16_F" //F16 Fighting falcon
]];

//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default, ["NLD_NFPT_rifleman"]];

_inf set [T_INF_SL, ["NLD_NFPT_SL"]];
_inf set [T_INF_TL, ["NLD_NFPT_TL"]];
_inf set [T_INF_officer, ["NLD_NFPT_OFF"]];
_inf set [T_INF_GL, ["NLD_NFPT_GL"]];
_inf set [T_INF_rifleman, ["NLD_NFPT_rifleman"]];
_inf set [T_INF_marksman, ["NLD_NFPT_SLA"]];
_inf set [T_INF_sniper, ["NLD_NFPT_SLA"]];
_inf set [T_INF_spotter, ["NLD_NFPT_SLA"]];
_inf set [T_INF_exp, ["NLD_NFPT_EXPL"]];
_inf set [T_INF_ammo, ["NLD_NFPT_Ammo", "NLD_NFPT_AAA", "NLD_NFPT_AAR", "NLD_NFPT_AMAT", "NLD_NFPT_AMMG"]];
_inf set [T_INF_LAT, ["NLD_NFPT_LAT4", "NLD_NFPT_LAT"]];
_inf set [T_INF_AT, ["NLD_NFPT_MAT"]];
_inf set [T_INF_AA, ["NLD_NFPT_AA"]];
_inf set [T_INF_LMG, ["NLD_NFPT_AR"]];
_inf set [T_INF_HMG, ["NLD_NFPT_MMG"]];
_inf set [T_INF_medic, ["NLD_NFPT_CLS"]];
_inf set [T_INF_engineer, ["NLD_NFPT_ENGI"]];
_inf set [T_INF_crew, ["NLD_Crew"]];
_inf set [T_INF_crew_heli, ["NLD_Helicrew"]];
_inf set [T_INF_pilot, ["NLD_Helipilot"]];
_inf set [T_INF_pilot_heli, ["NLD_Pilot_F16"]];
//_inf set [T_INF_survivor, [""]];
//_inf set [T_INF_unarmed, [""]];

// Recon
_inf set [T_INF_recon_TL, ["NLD_MTP_TL"]];
_inf set [T_INF_recon_rifleman, ["NLD_MTP_Operator", "NLD_MTP_Operator_MP5"]];
_inf set [T_INF_recon_medic, ["NLD_MTP_MEDIC"]];
_inf set [T_INF_recon_exp, ["NLD_MTP_DEMSPEC"]];
_inf set [T_INF_recon_LAT, ["NLD_MTP_LAT", "NLD_MTP_AT"]];
_inf set [T_INF_recon_marksman, ["NLD_MTP_SLA"]];
_inf set [T_INF_recon_JTAC, ["NLD_MTP_COMSPEC"]];


// Divers, still vanilla
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];



//==== Vehicles ====
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["NLD_DST_Fennek"]];

_veh set [T_VEH_car_unarmed, ["NLD_DST_Fennek"]];
_veh set [T_VEH_car_armed, ["NLD_DST_VECTOR_ARMED"]];

_veh set [T_VEH_MRAP_unarmed, ["NLD_DST_Fennek"]];
_veh set [T_VEH_MRAP_HMG, ["NLD_DST_Fennek_HMG"]];
_veh set [T_VEH_MRAP_GMG, ["NLD_DST_Fennek_GMG"]];

_veh set [T_VEH_IFV, ["NLD_Boxer_m2", "NLD_Boxer_mk19", "NLD_WLD_CV9035NL", "NLD_YPR_765"]];
_veh set [T_VEH_APC, ["NLD_Boxer_m2", "NLD_Boxer_mk19"]];
_veh set [T_VEH_MBT, ["NLD_WLD_Leo2", "NLD_Leopard2A6"]];
_veh set [T_VEH_MRLS, ["NLD_MLRS_M270_DPICM", "NLD_MLRS_M270_HE"]];
_veh set [T_VEH_SPA, ["NLD_WLD_PzH2000NL"]];
//_veh set [T_VEH_SPAA, ["rhs_zsu234_aa", "RHS_Ural_Zu23_MSV_01"]];

_veh set [T_VEH_stat_HMG_high, ["CUP_B_M2StaticMG_USMC"]];
_veh set [T_VEH_stat_GMG_high, ["B_GMG_01_high_F"]];
_veh set [T_VEH_stat_HMG_low, ["CUP_B_M2StaticMG_MiniTripod_USMC"]];
_veh set [T_VEH_stat_GMG_low, ["B_GMG_01_F"]];
//_veh set [T_VEH_stat_AA, [""]];
//_veh set [T_VEH_stat_AT, [""]];

_veh set [T_VEH_stat_mortar_light, ["B_Mortar_01_F"]];
_veh set [T_VEH_stat_mortar_heavy, ["B_Mortar_01_F"]];

_veh set [T_VEH_heli_light, ["CUP_B_MH6J_USA", "NLD_NH90", "NLD_Lynx"]];
_veh set [T_VEH_heli_heavy, ["NLD_CH47D_Armed","NLD_CH47D_VIV","NLD_CH47F_Armed","NLD_CH47F_ViV"]];
_veh set [T_VEH_heli_cargo, ["NLD_NH90", "NLD_Lynx"]];
_veh set [T_VEH_heli_attack, ["NLD_AH64D", "NLD_Lynx_Hellfire"]];

_veh set [T_VEH_plane_attack, ["NLD_F16", "NLD_F35"]];
_veh set [T_VEH_plane_fighter, ["NLD_F16", "NLD_F35"]];
_veh set [T_VEH_plane_cargo, ["NLD_C130H"]];
_veh set [T_VEH_plane_unarmed, ["NLD_C130H", "NLD_F35_Stealth"]];
//_veh set [T_VEH_plane_VTOL, [""]];

_veh set [T_VEH_boat_unarmed, ["NLD_RHIB"]];
_veh set [T_VEH_boat_armed, ["NLD_FRISC"]];

_veh set [T_VEH_personal, ["NLD_Quad"]];

_veh set [T_VEH_truck_inf, ["NLD_DAF_Transport", "NLD_DAF_Transport_Covered"]];
_veh set [T_VEH_truck_cargo, ["NLD_DAF_Transport", "NLD_DAF_Transport_Covered"]];
_veh set [T_VEH_truck_ammo, ["NLD_DAF_ammo"]];
_veh set [T_VEH_truck_repair, ["NLD_DAF_repair"]];
_veh set [T_VEH_truck_medical	, ["NLD_DAF_medical"]];
_veh set [T_VEH_truck_fuel, ["NLD_DAF_Fuel"]];

//_veh set [T_VEH_submarine, ["B_SDV_01_F"]];

//==== Drones ====
_drone = []; _drone resize T_DRONE_SIZE;
//_drone set [T_DRONE_SIZE-1, nil];
//_drone set [T_DRONE_DEFAULT, ["I_UGV_01_F"]];
//_drone set [T_DRONE_UGV_unarmed, ["I_UGV_01_F"]];
//_drone set [T_DRONE_UGV_armed, ["I_UGV_01_rcws_F"]];
//_drone set [T_DRONE_plane_attack, ["I_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_plane_unarmed, ["I_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_heli_attack, ["I_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_quadcopter, ["I_UAV_01_F"]];
//_drone set [T_DRONE_designator, [""]];
//_drone set [T_DRONE_stat_HMG_low, ["I_HMG_01_A_F"]];
//_drone set [T_DRONE_stat_GMG_low, ["I_GMG_01_A_F"]];
//_drone set [T_DRONE_stat_AA, [""]];

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

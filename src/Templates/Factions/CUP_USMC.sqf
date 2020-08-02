/*
 _   _ ________  ________ 
| | | /  ___|  \/  /  __ \
| | | \ `--.| .  . | /  \/
| | | |`--. \ |\/| | |    
| |_| /\__/ / |  | | \__/\
 \___/\____/\_|  |_/\____/                                                                   
                       
*/

_array = [];

_array set [T_SIZE-1, nil];

_array set [T_NAME, "tCUP_USMC"]; // 														Template name + variable (not displayed)
_array set [T_DESCRIPTION, "CUP United States Marines."]; // 			Template display description
_array set [T_DISPLAY_NAME, "CUP USMC"]; // 											Template display name
_array set [T_FACTION, T_FACTION_military]; // 											Faction type: police, T_FACTION_military, T_FACTION_Police
_array set [T_REQUIRED_ADDONS, ["CUP_Creatures_Military_USMC","CUP_Vehicles_Core"]]; // 								Addons required to play this template

/* Infantry unit classes */
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default,  ["CUP_B_USMC_Soldier"]];					//Default infantry if nothing is found
_inf set [T_INF_SL, ["CUP_B_USMC_Soldier_SL"]]; // = 1
_inf set [T_INF_TL, ["CUP_B_USMC_Soldier_TL"]]; // = 2
_inf set [T_INF_officer, ["CUP_B_USMC_Officer"]]; // = 3
_inf set [T_INF_GL, ["CUP_B_USMC_Soldier_GL"]]; // = 4
_inf set [T_INF_rifleman, ["CUP_B_USMC_Soldier"]]; // = 5
_inf set [T_INF_marksman, ["CUP_B_USMC_Soldier_Marksman"]]; // = 6
_inf set [T_INF_sniper, ["CUP_B_USMC_Sniper_M40A3","CUP_B_USMC_Sniper_M107"]]; // = 7
_inf set [T_INF_spotter, ["CUP_B_USMC_Spotter"]]; // = 8
_inf set [T_INF_exp, ["CUP_B_USMC_Engineer"]]; // = 9
_inf set [T_INF_ammo, ["CUP_B_USMC_Soldier"]]; // = 10
_inf set [T_INF_LAT, ["CUP_B_USMC_Soldier_LAT"]]; // = 11
_inf set [T_INF_AT, ["CUP_B_USMC_Soldier_AT","CUP_B_USMC_Soldier_HAT"]]; // = 12
_inf set [T_INF_AA, ["CUP_B_USMC_Soldier_AA"]]; // = 13
_inf set [T_INF_LMG, ["CUP_B_USMC_Soldier_AR"]]; // = 14
_inf set [T_INF_HMG, ["CUP_B_USMC_Soldier_MG"]]; // = 15
_inf set [T_INF_medic, ["CUP_B_USMC_Medic"]]; // = 16
_inf set [T_INF_engineer, ["CUP_B_USMC_Engineer"]]; // = 17 
_inf set [T_INF_crew, ["CUP_B_USMC_Crew"]]; // = 18
_inf set [T_INF_crew_heli, ["CUP_B_USMC_Pilot"]]; // = 19
_inf set [T_INF_pilot, ["CUP_B_USMC_Pilot"]]; // = 20
_inf set [T_INF_pilot_heli, ["CUP_B_USMC_Pilot"]]; // = 21
_inf set [T_INF_survivor, ["CUP_B_USMC_Soldier_Light"]]; // = 22
_inf set [T_INF_unarmed, ["CUP_B_USMC_Soldier_Light"]]; // = 23
/* Recon unit classes */
_inf set [T_INF_recon_TL, ["CUP_B_FR_Soldier_TL"]]; // = 24
_inf set [T_INF_recon_rifleman, ["CUP_B_FR_Soldier_Operator"]]; // = 25
_inf set [T_INF_recon_medic, ["CUP_B_FR_Medic"]]; // = 26
_inf set [T_INF_recon_exp, ["CUP_B_FR_Soldier_Exp"]]; // = 27
_inf set [T_INF_recon_LAT, ["CUP_B_FR_Soldier_Operator"]]; // = 28
_inf set [T_INF_recon_marksman, ["CUP_B_FR_Soldier_Marksman"]]; // = 29
_inf set [T_INF_recon_JTAC, ["CUP_B_FR_Soldier_Operator"]]; // = 30

/* Vehicle classes */
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["CUP_B_HMMWV_Unarmed_USMC","CUP_B_M1151_USMC","CUP_B_M1152_USMC"]]; // = 0 Default if nothing found
_veh set [T_VEH_car_unarmed, ["CUP_B_HMMWV_Unarmed_USMC","CUP_B_M1151_USMC","CUP_B_M1152_USMC"]]; // = 1 – REQUIRED
_veh set [T_VEH_car_armed, ["CUP_B_HMMWV_M1114_USMC","CUP_B_HMMWV_M2_USMC","CUP_B_M1151_M2_USMC","CUP_B_M1165_GMV_USMC"]]; // = 2
_veh set [T_VEH_MRAP_unarmed, ["CUP_B_HMMWV_Unarmed_USMC","CUP_B_M1151_USMC","CUP_B_M1152_USMC"]]; // = 3 – REQUIRED
_veh set [T_VEH_MRAP_HMG, ["CUP_B_HMMWV_M1114_USMC","CUP_B_HMMWV_M2_USMC","CUP_B_M1151_M2_USMC","CUP_B_M1165_GMV_USMC","CUP_B_RG31E_M2_OD_USMC","CUP_B_RG31_M2_OD_USMC","CUP_B_RG31_M2_OD_GC_USMC"]]; // = 4 – REQUIRED
_veh set [T_VEH_MRAP_GMG, ["CUP_B_HMMWV_MK19_USMC","CUP_B_M1151_Mk19_USMC","CUP_B_RG31_Mk19_OD_USMC"]]; // = 5 – REQUIRED
_veh set [T_VEH_IFV, ["CUP_B_AAV_USMC","CUP_B_AAV_Unarmed_USMC"]]; // = 6 – REQUIRED
_veh set [T_VEH_APC, ["CUP_B_LAV25_HQ_USMC","CUP_B_LAV25_HQ_green","CUP_B_LAV25M240_USMC","CUP_B_LAV25M240_green"]]; // = 7 – REQUIRED
_veh set [T_VEH_MBT, ["CUP_B_M1A1_Woodland_USMC","CUP_B_M1A2_TUSK_MG_USMC"]]; // = 8 – REQUIRED
_veh set [T_VEH_MRLS, ["CUP_B_M270_DPICM_USMC","CUP_B_M270_HE_USMC"]]; // = 9
_veh set [T_VEH_SPA, ["CUP_B_M270_DPICM_USMC","CUP_B_M270_HE_USMC"]]; // = 10
_veh set [T_VEH_SPAA, ["CUP_B_HMMWV_Avenger_USMC"]]; // = 11
_veh set [T_VEH_stat_HMG_high, ["CUP_B_M2StaticMG_USMC"]]; // = 12 – REQUIRED
_veh set [T_VEH_stat_HMG_low, ["CUP_B_M2StaticMG_MiniTripod_USMC"]]; // = 14
_veh set [T_VEH_stat_AT, ["CUP_B_TOW2_TriPod_USMC","CUP_B_M119_USMC"]]; // = 17
_veh set [T_VEH_stat_mortar_light, ["CUP_B_M252_USMC"]]; // = 18 - REQUIRED
_veh set [T_VEH_heli_light, ["CUP_B_UH1Y_UNA_USMC"]]; // = 20
_veh set [T_VEH_heli_heavy, ["CUP_B_MH60S_USMC"]]; // = 21
_veh set [T_VEH_heli_cargo, ["CUP_B_CH53E_USMC"]]; // = 22
_veh set [T_VEH_heli_attack, ["CUP_B_AH1Z_Dynamic_USMC"]]; // = 23
_veh set [T_VEH_plane_attack, ["CUP_B_AV8B_DYN_USMC"]]; // = 24
_veh set [T_VEH_plane_fighter , ["CUP_B_F35B_USMC"]]; // = 25
_veh set [T_VEH_boat_unarmed, ["CUP_B_LCU1600_USMC","CUP_B_Zodiac_USMC"]]; // = 29
_veh set [T_VEH_personal, ["CUP_B_M1030_USMC","CUP_B_M1151_USMC"]]; // = 31
_veh set [T_VEH_truck_inf, ["CUP_B_MTVR_USMC"]]; // = 32 – REQUIRED
_veh set [T_VEH_truck_cargo, ["CUP_B_MTVR_USMC"]]; // = 33
_veh set [T_VEH_truck_ammo, ["CUP_B_MTVR_Ammo_USMC"]]; // = 34 – REQUIRED
_veh set [T_VEH_truck_repair, ["CUP_B_MTVR_Repair_USMC"]]; // = 35
_veh set [T_VEH_truck_medical , ["CUP_B_HMMWV_Ambulance_USMC"]]; // = 36
_veh set [T_VEH_truck_fuel, ["CUP_B_MTVR_Refuel_USMC"]]; // = 37

/* Drone classes */
_drone = []; _drone resize T_DRONE_SIZE;
_drone set [T_DRONE_SIZE-1, nil];
_veh set [T_DRONE_DEFAULT , ["CUP_B_USMC_DYN_MQ9"]];

_drone set [T_DRONE_plane_attack, ["CUP_B_USMC_DYN_MQ9"]]; // = 2


/* Cargo classes */
_cargo = +(tDefault select T_CARGO);

/* Group templates */
_group = +(tDefault select T_GROUP);

/* Set arrays */
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];


_array /* END OF TEMPLATE */
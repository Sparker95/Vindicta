
_array = [];

_array set [T_SIZE-1, nil];

_array set [T_NAME, "tCUP_CDF"]; // 														Template name + variable (not displayed)
_array set [T_DESCRIPTION, "Chernarus Defense Force."]; // 			Template display description
_array set [T_DISPLAY_NAME, "CUP CDF"]; // 											Template display name
_array set [T_FACTION, T_FACTION_military]; // 											Faction type: police, T_FACTION_military, T_FACTION_Police
_array set [T_REQUIRED_ADDONS, ["CUP_Creatures_Military_Russia","CUP_Vehicles_Core"]]; // 								Addons required to play this template


/* Infantry unit classes */
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default,  ["CUP_B_CDF_Soldier_FST"]];					//Default infantry if nothing is found

_inf set [T_INF_SL, ["CUP_B_CDF_Soldier_TL_FST"]]; // = 1
_inf set [T_INF_TL, ["CUP_B_CDF_Soldier_TL_FST"]]; // = 2
_inf set [T_INF_officer, ["CUP_B_CDF_Officer_FST"]]; // = 3
_inf set [T_INF_GL, ["CUP_B_CDF_Soldier_GL_FST"]]; // = 4
_inf set [T_INF_rifleman, ["CUP_B_CDF_Soldier_FST"]]; // = 5
_inf set [T_INF_marksman, ["CUP_B_CDF_Soldier_Marksman_FST"]]; // = 6
_inf set [T_INF_sniper, ["CUP_B_CDF_Sniper_FST"]]; // = 7
_inf set [T_INF_spotter, ["CUP_B_CDF_Spotter_FST"]]; // = 8
_inf set [T_INF_exp, ["CUP_B_CDF_Engineer_FST"]]; // = 9
_inf set [T_INF_ammo, ["CUP_B_CDF_Soldier_AAT_FST", "CUP_B_CDF_Soldier_AMG_FST"]]; // = 10
_inf set [T_INF_LAT, ["CUP_B_CDF_Soldier_RPG18_FST"]]; // = 11
_inf set [T_INF_AT, ["CUP_B_CDF_Soldier_LAT_FST"]]; // = 12
_inf set [T_INF_AA, ["CUP_B_CDF_Soldier_AA_FST"]]; // = 13
_inf set [T_INF_LMG, ["CUP_B_CDF_Soldier_AR_FST"]]; // = 14
_inf set [T_INF_HMG, ["CUP_B_CDF_Soldier_MG_FST"]]; // = 15
_inf set [T_INF_medic, ["CUP_B_CDF_Medic_FST"]]; // = 16
_inf set [T_INF_engineer, ["CUP_B_CDF_Engineer_FST"]]; // = 17 
_inf set [T_INF_crew, ["CUP_B_CDF_Crew_FST"]]; // = 18
_inf set [T_INF_crew_heli, ["CUP_B_CDF_Crew_FST"]]; // = 19
_inf set [T_INF_pilot, ["CUP_B_CDF_Pilot_FST"]]; // = 20
_inf set [T_INF_pilot_heli, ["CUP_B_CDF_Pilot_FST"]]; // = 21
// _inf set [T_INF_survivor, ["CUP_O_RU_Soldier_Light_M_EMR"]]; // = 22
// _inf set [T_INF_unarmed, ["CUP_O_RU_Soldier_Light_M_EMR"]]; // = 23
/* Recon unit classes */
_inf set [T_INF_recon_TL, ["CUP_B_CDF_Soldier_TL_MNT"]]; // = 24
_inf set [T_INF_recon_rifleman, ["CUP_B_CDF_Soldier_MNT"]]; // = 25
_inf set [T_INF_recon_medic, ["CUP_B_CDF_Medic_MNT"]]; // = 26
_inf set [T_INF_recon_exp, ["CUP_B_CDF_Engineer_MNT"]]; // = 27
_inf set [T_INF_recon_LAT, ["CUP_B_CDF_Soldier_RPG18_MNT"]]; // = 28
_inf set [T_INF_recon_marksman, ["CUP_B_CDF_Soldier_Marksman_MNT"]]; // = 29
_inf set [T_INF_recon_JTAC, ["CUP_B_CDF_Spotter_MNT"]]; // = 30

/* Vehicle classes */
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["CUP_B_UAZ_Unarmed_CDF"]]; // = 0 Default if nothing found
_veh set [T_VEH_car_unarmed, ["CUP_B_UAZ_Unarmed_CDF", "CUP_B_UAZ_Open_CDF"]]; // = 1 – REQUIRED
_veh set [T_VEH_car_armed, ["CUP_B_UAZ_MG_CDF"]]; // = 2
_veh set [T_VEH_MRAP_unarmed, ["CUP_B_UAZ_Unarmed_CDF", "CUP_B_UAZ_Open_CDF"]]; // = 3 – REQUIRED
_veh set [T_VEH_MRAP_HMG, ["CUP_B_UAZ_MG_CDF"]]; // = 4 – REQUIRED
_veh set [T_VEH_MRAP_GMG, ["CUP_B_UAZ_AGS30_CDF","CUP_B_UAZ_SPG9_CDF","CUP_B_UAZ_METIS_CDF"]]; // = 5 – REQUIRED
_veh set [T_VEH_IFV, ["CUP_B_BMP2_CDF"]]; // = 6 – REQUIRED
_veh set [T_VEH_APC, ["CUP_B_BTR60_CDF","CUP_B_BTR80_CDF", "CUP_B_BTR80A_CDF", "CUP_B_MTLB_pk_CDF", "CUP_B_BRDM2_CDF"]]; // = 7 – REQUIRED
_veh set [T_VEH_MBT, ["CUP_B_T72_CDF"]]; // = 8 – REQUIRED
_veh set [T_VEH_MRLS, ["CUP_B_BM21_CDF"]]; // = 9
_veh set [T_VEH_SPA, ["CUP_B_BM21_CDF"]]; // = 10
_veh set [T_VEH_SPAA, ["CUP_B_ZSU23_CDF","CUP_B_Ural_ZU23_CDF"]]; // = 11
_veh set [T_VEH_stat_HMG_high, ["CUP_B_DSHKM_CDF"]]; // = 12 – REQUIRED
_veh set [T_VEH_stat_HMG_low, ["CUP_B_DSHkM_MiniTriPod_CDF"]]; // = 14
_veh set [T_VEH_stat_GMG_low, ["CUP_B_AGS_CDF"]]; // = 15
_veh set [T_VEH_stat_AA, ["CUP_B_ZU23_CDF", "CUP_B_Igla_AA_pod_CDF"]]; // = 16
_veh set [T_VEH_stat_AT, ["CUP_B_SPG9_CDF"]]; // = 17
_veh set [T_VEH_stat_mortar_light, ["CUP_B_2b14_82mm_CDF"]]; // = 18 - REQUIRED
_veh set [T_VEH_heli_light, ["CUP_B_Mi17_CDF"]]; // = 20
_veh set [T_VEH_heli_heavy, ["CUP_B_Mi17_CDF"]]; // = 21
_veh set [T_VEH_heli_cargo, ["CUP_B_MI6T_CDF"]]; // = 22
_veh set [T_VEH_heli_attack, ["CUP_B_Mi171Sh_CDF"]]; // = 23
// _veh set [T_VEH_plane_attack, ["CUP_O_Su25_Dyn_RU"]]; // = 24
// _veh set [T_VEH_plane_fighter , ["CUP_O_SU34_RU"]]; // = 25
// _veh set [T_VEH_boat_unarmed, ["CUP_O_PBX_RU"]]; // = 29
// _veh set [T_VEH_personal, ["CUP_O_UAZ_Unarmed_RU","CUP_O_UAZ_Open_RU"]]; // = 31
_veh set [T_VEH_truck_inf, ["CUP_B_Kamaz_CDF","CUP_B_Kamaz_Open_CDF"]]; // = 32 – REQUIRED
_veh set [T_VEH_truck_cargo, ["CUP_B_Kamaz_CDF"]]; // = 33
_veh set [T_VEH_truck_ammo, ["CUP_B_Kamaz_Reammo_CDF"]]; // = 34 – REQUIRED
_veh set [T_VEH_truck_repair, ["CUP_B_Kamaz_Repair_CDF"]]; // = 35
_veh set [T_VEH_truck_medical , ["CUP_B_S1203_Ambulance_CDF"]]; // = 36
_veh set [T_VEH_truck_fuel, ["CUP_B_Kamaz_Refuel_CDF"]]; // = 37

/* Drone classes */
_drone = []; _drone resize T_DRONE_SIZE;
_drone set [T_DRONE_SIZE-1, nil];
_veh set [T_DRONE_DEFAULT , ["CUP_O_Pchela1T_RU"]];

_drone set [T_DRONE_plane_attack, ["CUP_O_Pchela1T_RU"]]; // = 2


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
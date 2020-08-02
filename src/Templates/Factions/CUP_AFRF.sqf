/*
 _____  ___    ___    ___   
(  _  )(  _`\ |  _`\ (  _`\ 
| (_) || (_(_)| (_) )| (_(_)
|  _  ||  _)  | ,  / |  _)  
| | | || |    | |\ \ | |    
(_) (_)(_)    (_) (_)(_)                               
                       
*/

_array = [];

_array set [T_SIZE-1, nil];

_array set [T_NAME, "tCUP_AFRF"]; // 														Template name + variable (not displayed)
_array set [T_DESCRIPTION, "United Forces of the Russian Federation."]; // 			Template display description
_array set [T_DISPLAY_NAME, "CUP AFRF"]; // 											Template display name
_array set [T_FACTION, T_FACTION_military]; // 											Faction type: police, T_FACTION_military, T_FACTION_Police
_array set [T_REQUIRED_ADDONS, ["CUP_Creatures_Military_Russia","CUP_Vehicles_Core"]]; // 								Addons required to play this template


/* Infantry unit classes */
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default,  ["CUP_O_RU_Soldier_M_EMR"]];					//Default infantry if nothing is found

_inf set [T_INF_SL, ["CUP_O_RU_Soldier_SL_M_EMR"]]; // = 1
_inf set [T_INF_TL, ["CUP_O_RU_Soldier_TL_M_EMR"]]; // = 2
_inf set [T_INF_officer, ["CUP_O_RU_Officer_M_EMR"]]; // = 3
_inf set [T_INF_GL, ["CUP_O_RU_Soldier_GL_M_EMR"]]; // = 4
_inf set [T_INF_rifleman, ["CUP_O_RU_Soldier_M_EMR"]]; // = 5
_inf set [T_INF_marksman, ["CUP_O_RU_Soldier_Marksman_M_EMR"]]; // = 6
_inf set [T_INF_sniper, ["CUP_O_RU_Sniper_M_EMR","CUP_O_RU_Sniper_KSVK_M_EMR"]]; // = 7
_inf set [T_INF_spotter, ["CUP_O_RU_Spotter_M_EMR"]]; // = 8
_inf set [T_INF_exp, ["CUP_O_RU_Explosive_Specialist_M_EMR"]]; // = 9
_inf set [T_INF_ammo, ["CUP_O_RU_Soldier_M_EMR"]]; // = 10
_inf set [T_INF_LAT, ["CUP_O_RU_Soldier_LAT_M_EMR", "CUP_O_RU_Soldier_AT_M_EMR"]]; // = 11
_inf set [T_INF_AT, ["CUP_O_RU_Soldier_HAT_M_EMR"]]; // = 12
_inf set [T_INF_AA, ["CUP_O_RU_Soldier_AA_M_EMR"]]; // = 13
_inf set [T_INF_LMG, ["CUP_O_RU_Soldier_AR_M_EMR"]]; // = 14
_inf set [T_INF_HMG, ["CUP_O_RU_Soldier_MG_M_EMR"]]; // = 15
_inf set [T_INF_medic, ["CUP_O_RU_Medic_M_EMR"]]; // = 16
_inf set [T_INF_engineer, ["CUP_O_RU_Engineer_M_EMR"]]; // = 17 
_inf set [T_INF_crew, ["CUP_O_RU_Crew_M_EMR"]]; // = 18
_inf set [T_INF_crew_heli, ["CUP_O_RU_Pilot_M_EMR"]]; // = 19
_inf set [T_INF_pilot, ["CUP_O_RU_Pilot_M_EMR"]]; // = 20
_inf set [T_INF_pilot_heli, ["CUP_O_RU_Pilot_M_EMR"]]; // = 21
_inf set [T_INF_survivor, ["CUP_O_RU_Soldier_Light_M_EMR"]]; // = 22
_inf set [T_INF_unarmed, ["CUP_O_RU_Soldier_Light_M_EMR"]]; // = 23
/* Recon unit classes */
_inf set [T_INF_recon_TL, ["CUP_O_RUS_Soldier_TL"]]; // = 24
_inf set [T_INF_recon_rifleman, ["CUP_O_RUS_SpecOps_Scout","CUP_O_RUS_SpecOps","CUP_O_RUS_Soldier_GL"]]; // = 25
_inf set [T_INF_recon_medic, ["CUP_O_RUS_SpecOps_Scout","CUP_O_RUS_SpecOps","CUP_O_RUS_Soldier_GL"]]; // = 26
_inf set [T_INF_recon_exp, ["CUP_O_RUS_Saboteur"]]; // = 27
_inf set [T_INF_recon_LAT, ["CUP_O_RUS_SpecOps_Scout","CUP_O_RUS_SpecOps","CUP_O_RUS_Soldier_GL"]]; // = 28
_inf set [T_INF_recon_marksman, ["CUP_O_RUS_Soldier_Marksman"]]; // = 29
_inf set [T_INF_recon_JTAC, ["CUP_O_RUS_SpecOps_Scout","CUP_O_RUS_SpecOps","CUP_O_RUS_Soldier_GL"]]; // = 30

/* Vehicle classes */
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["CUP_O_UAZ_Unarmed_RU"]]; // = 0 Default if nothing found
_veh set [T_VEH_car_unarmed, ["CUP_O_UAZ_Unarmed_RU","CUP_O_UAZ_Open_RU","CUP_O_UAZ_AMB_RU"]]; // = 1 – REQUIRED
_veh set [T_VEH_car_armed, ["CUP_O_UAZ_MG_RU","CUP_O_GAZ_Vodnik_PK_RU","CUP_O_GAZ_Vodnik_AGS_RU"]]; // = 2
_veh set [T_VEH_MRAP_unarmed, ["CUP_O_UAZ_Unarmed_RU","CUP_O_UAZ_Open_RU","CUP_O_UAZ_AMB_RU"]]; // = 3 – REQUIRED
_veh set [T_VEH_MRAP_HMG, ["CUP_O_UAZ_MG_RU"]]; // = 4 – REQUIRED
_veh set [T_VEH_MRAP_GMG, ["CUP_O_UAZ_AGS30_RU","CUP_O_UAZ_SPG9_RU","CUP_O_UAZ_METIS_RU"]]; // = 5 – REQUIRED
_veh set [T_VEH_IFV, ["CUP_O_BMP2_RU"]]; // = 6 – REQUIRED
_veh set [T_VEH_APC, ["CUP_O_BTR80A_GREEN_RU","CUP_O_BTR90_RU"]]; // = 7 – REQUIRED
_veh set [T_VEH_MBT, ["CUP_O_T72_RU", "CUP_O_T90_RU"]]; // = 8 – REQUIRED
_veh set [T_VEH_MRLS, ["CUP_O_BM21_RU"]]; // = 9
_veh set [T_VEH_SPA, ["CUP_O_BM21_RU"]]; // = 10
_veh set [T_VEH_SPAA, ["CUP_O_2S6_RU","CUP_O_2S6M_RU"]]; // = 11
_veh set [T_VEH_stat_HMG_high, ["CUP_O_KORD_high_RU"]]; // = 12 – REQUIRED
_veh set [T_VEH_stat_HMG_low, ["CUP_O_KORD_RU"]]; // = 14
_veh set [T_VEH_stat_GMG_low, ["CUP_O_AGS_RU"]]; // = 15
_veh set [T_VEH_stat_AA, ["CUP_O_Igla_AA_pod_RU","CUP_O_ZU23_RU"]]; // = 16
_veh set [T_VEH_stat_AT, ["CUP_O_D30_AT_RU","CUP_O_Metis_RU"]]; // = 17
_veh set [T_VEH_stat_mortar_light, ["CUP_O_2b14_82mm_RU"]]; // = 18 - REQUIRED
_veh set [T_VEH_heli_light, ["CUP_O_Ka60_Grey_RU"]]; // = 20
_veh set [T_VEH_heli_heavy, ["CUP_O_Mi24_P_Dynamic_RU"]]; // = 21
_veh set [T_VEH_heli_cargo, ["CUP_O_Mi8_RU"]]; // = 22
_veh set [T_VEH_heli_attack, ["CUP_O_Ka52_RU"]]; // = 23
_veh set [T_VEH_plane_attack, ["CUP_O_Su25_Dyn_RU"]]; // = 24
_veh set [T_VEH_plane_fighter , ["CUP_O_SU34_RU"]]; // = 25
_veh set [T_VEH_boat_unarmed, ["CUP_O_PBX_RU"]]; // = 29
_veh set [T_VEH_personal, ["CUP_O_UAZ_Unarmed_RU","CUP_O_UAZ_Open_RU"]]; // = 31
_veh set [T_VEH_truck_inf, ["CUP_O_Ural_Open_RU","CUP_O_Kamaz_Open_RU"]]; // = 32 – REQUIRED
_veh set [T_VEH_truck_cargo, ["CUP_O_Kamaz_RU"]]; // = 33
_veh set [T_VEH_truck_ammo, ["CUP_O_Ural_Reammo_RU","CUP_O_Kamaz_Reammo_RU"]]; // = 34 – REQUIRED
_veh set [T_VEH_truck_repair, ["CUP_O_Kamaz_Repair_RU","CUP_O_Ural_Repair_RU"]]; // = 35
_veh set [T_VEH_truck_medical , ["CUP_O_GAZ_Vodnik_MedEvac_RU"]]; // = 36
_veh set [T_VEH_truck_fuel, ["CUP_O_Kamaz_Refuel_RU","CUP_O_Ural_Refuel_RU"]]; // = 37

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
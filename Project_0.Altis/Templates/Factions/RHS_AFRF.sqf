/*
RHS AFRF: Russia (VMF) templates for ARMA III
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

//==== Infantry ====
_inf = +(tDefault select T_INF);
_inf set [T_INF_SIZE-1, nil]; 								//Make an array full of nil
_inf set [T_INF_DEFAULT, ["rhs_vmf_flora_rifleman"]];

_inf set [T_INF_SL, ["rhs_vmf_flora_sergeant"]];
_inf set [T_INF_TL, ["rhs_vmf_flora_junior_sergeant"]];
_inf set [T_INF_officer, ["rhs_vmf_flora_officer_armored"]];
_inf set [T_INF_GL, ["rhs_vmf_flora_grenadier"]];
_inf set [T_INF_rifleman, ["rhs_vmf_flora_rifleman", "rhs_vmf_flora_RShG2"]];
_inf set [T_INF_marksman, ["rhs_vmf_flora_marksman"]];
_inf set [T_INF_sniper, ["rhs_vmf_flora_marksman"]];
_inf set [T_INF_spotter, ["rhs_vmf_flora_officer"]];
_inf set [T_INF_exp, ["rhs_vmf_flora_engineer"]];
_inf set [T_INF_ammo, ["rhs_vmf_flora_machinegunner_assistant", "rhs_vmf_flora_strelok_rpg_assist"]];
_inf set [T_INF_LAT, ["rhs_vmf_flora_grenadier_rpg"]];
_inf set [T_INF_AT, ["rhs_vmf_flora_at"]];
_inf set [T_INF_AA, ["rhs_vmf_flora_aa"]];
_inf set [T_INF_LMG, ["rhs_vmf_flora_machinegunner"]];
//_inf set [T_INF_HMG, ["rhs_vmf_flora_machinegunner"]];
_inf set [T_INF_medic, ["rhs_vmf_flora_medic"]];
_inf set [T_INF_engineer, ["rhs_vmf_flora_engineer"]];
_inf set [T_INF_crew, ["rhs_vmf_flora_crew"]];
_inf set [T_INF_crew_heli, ["rhs_vmf_flora_combatcrew"]];
_inf set [T_INF_pilot, ["rhs_pilot"]];
_inf set [T_INF_pilot_heli, ["rhs_pilot_combat_heli"]];
_inf set [T_INF_survivor, ["rhs_vmf_flora_rifleman"]];
_inf set [T_INF_unarmed, ["rhs_vmf_flora_rifleman"]];

// Rcon
_inf set [T_INF_recon_TL, ["rhs_vmf_recon_sergeant"]];
_inf set [T_INF_recon_rifleman, ["rhs_vmf_recon_rifleman"]];
_inf set [T_INF_recon_medic, ["rhs_vmf_recon_medic"]];
_inf set [T_INF_recon_exp, ["rhs_vmf_recon_grenadier"]];
_inf set [T_INF_recon_LAT, ["rhs_vmf_recon_rifleman_lat"]];
_inf set [T_INF_recon_marksman, ["rhs_vmf_recon_marksman"]];
_inf set [T_INF_recon_JTAC, ["rhs_vmf_recon_rifleman_asval"]];


// Divers, still vanilla
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];



//==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["rhs_uaz_vmf"]];

_veh set [T_VEH_car_unarmed, ["rhs_uaz_vmf"]];
_veh set [T_VEH_car_armed, ["rhs_uaz_open_vv"]];

_veh set [T_VEH_MRAP_unarmed, ["rhs_tigr_vmf", "rhs_tigr_m_vmf"]];
_veh set [T_VEH_MRAP_HMG, ["rhs_tigr_sts_vmf"]];
_veh set [T_VEH_MRAP_GMG, ["rhs_tigr_sts_vmf"]];

_veh set [T_VEH_IFV, ["rhs_bmp1_vmf", "rhs_bmp1d_vmf", "rhs_bmp1k_vmf", "rhs_bmp1p_vmf", "rhs_bmp2e_vmf", "rhs_bmp2_vmf", "rhs_bmp2d_vmf", "rhs_bmp2k_vmf", "rhs_brm1k_vmf", "rhs_prp3_vmf"]];
_veh set [T_VEH_APC, ["rhs_btr60_vmf", "rhs_btr70_vmf", "rhs_btr80_vmf", "rhs_btr80a_vmf"]];
_veh set [T_VEH_MBT, ["rhs_sprut_vdv", "rhs_t80a", "rhs_t80bk", "rhs_t80bv", "rhs_t80bvk", "rhs_t80u", "rhs_t80uk", "rhs_t80um", "rhs_t90_tv", "rhs_t90a_tv"]];
_veh set [T_VEH_MRLS, ["RHS_BM21_VMF_01"]];
_veh set [T_VEH_SPA, ["rhs_2s3_tv"]];
_veh set [T_VEH_SPAA, ["rhs_zsu234_aa", "rhs_gaz66_zu23_vmf"]];

_veh set [T_VEH_stat_HMG_high, ["rhs_KORD_high_VMF"]];
_veh set [T_VEH_stat_GMG_high, ["RHS_AGS30_TriPod_VMF"]];
_veh set [T_VEH_stat_HMG_low, ["rhs_KORD_VMF", "RHS_NSV_TriPod_VMF"]];
_veh set [T_VEH_stat_GMG_low, ["RHS_AGS30_TriPod_VMF"]];
_veh set [T_VEH_stat_AA, ["rhs_Igla_AA_pod_vmf"]];
_veh set [T_VEH_stat_AT, ["rhs_Kornet_9M133_2_vmf", "rhs_SPG9M_VMF"]];

_veh set [T_VEH_stat_mortar_light, ["rhs_2b14_82mm_vmf"]];
_veh set [T_VEH_stat_mortar_heavy, ["rhs_D30_vmf"]];

_veh set [T_VEH_heli_light, ["rhs_ka60_c"]];
_veh set [T_VEH_heli_heavy, ["RHS_Mi8AMT_vvsc", "RHS_Mi8AMTSh_vvsc", "RHS_Mi8mt_vvsc", "RHS_Mi8MTV3_heavy_vvsc"]];
_veh set [T_VEH_heli_cargo, ["RHS_Mi8mtv3_Cargo_vvsc"]];
_veh set [T_VEH_heli_attack, ["RHS_Ka52_vvsc", "RHS_Mi24V_vvsc", "RHS_Mi24P_vvsc", "RHS_Mi24Vt_vvsc"]];

_veh set [T_VEH_plane_attack, ["RHS_Su25SM_vvsc"]];
_veh set [T_VEH_plane_fighter, ["rhs_mig29s_vvsc", "RHS_T50_vvs_blueonblue", "RHS_T50_vvs_054", "RHS_T50_vvs_052"]];
_veh set [T_VEH_plane_cargo, ["RHS_TU95MS_vvs_old"]];
_veh set [T_VEH_plane_unarmed, ["RHS_TU95MS_vvs_old"]];
//_veh set [T_VEH_plane_VTOL, ["RHS_TU95MS_vvs_old"]];

_veh set [T_VEH_boat_unarmed, ["rhs_pts_vmf", "B_Boat_Transport_01_F"]];
//_veh set [T_VEH_boat_armed, ["B_Boat_Armed_01_minigun_F"]];

_veh set [T_VEH_personal, ["B_Quadbike_01_F"]];

_veh set [T_VEH_truck_inf, ["rhs_zil131_open_vmf", "RHS_Ural_VMF_01", "rhs_kamaz5350_open_vmf", "rhs_gaz66o_vmf", "rhs_gaz66_vmf", "RHS_Ural_Open_VMF_01"]];
_veh set [T_VEH_truck_cargo, ["rhs_kamaz5350_flatbed_cover_vmf", "rhs_gaz66_flat_vmf", "rhs_zil131_flatbed_cover_vmf", "rhs_zil131_flatbed_vmf", "RHS_Ural_Open_Flat_VMF_01"]];
_veh set [T_VEH_truck_ammo, ["rhs_gaz66_ammo_vmf"]];
_veh set [T_VEH_truck_repair, ["RHS_Ural_Repair_VMF_01"]];
_veh set [T_VEH_truck_medical , ["rhs_gaz66_ap2_vmf"]];
_veh set [T_VEH_truck_fuel, ["RHS_Ural_Fuel_VMF_01"]];

_veh set [T_VEH_submarine, ["B_SDV_01_F"]];


//==== Drones ====
_drone = +(tDefault select T_DRONE);
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
_group = [];
_group set [T_GROUP_SIZE-1, nil];
_group set [T_GROUP_DEFAULT, [configFile >> "CfgGroups" >> "East" >> "rhs_faction_vmf" >> "rhs_group_rus_vmf_infantry" >> "rhs_group_rus_vmf_infantry_fireteam"]];
_group set [T_GROUP_inf_AA_team, [configFile >> "CfgGroups" >> "East" >> "rhs_faction_vmf" >> "rhs_group_rus_vmf_infantry" >> "rhs_group_rus_vmf_infantry_section_AA"]];
_group set [T_GROUP_inf_AT_team, [configFile >> "CfgGroups" >> "East" >> "rhs_faction_vmf" >> "rhs_group_rus_vmf_infantry" >> "rhs_group_rus_vmf_infantry_section_AT"]];
_group set [T_GROUP_inf_rifle_squad, [configFile >> "CfgGroups" >> "East" >> "rhs_faction_vmf" >> "rhs_group_rus_vmf_infantry" >> "rhs_group_rus_vmf_infantry_squad"]];
_group set [T_GROUP_inf_assault_squad, [configFile >> "CfgGroups" >> "East" >> "rhs_faction_vmf" >> "rhs_group_rus_vmf_infantry" >> "rhs_group_rus_vmf_infantry_squad_2mg"]];
_group set [T_GROUP_inf_weapons_squad, [configFile >> "CfgGroups" >> "East" >> "rhs_faction_vmf" >> "rhs_group_rus_vmf_infantry" >> "rhs_group_rus_vmf_infantry_squad_sniper"]];
_group set [T_GROUP_inf_fire_team, [configFile >> "CfgGroups" >> "East" >> "rhs_faction_vmf" >> "rhs_group_rus_vmf_infantry" >> "rhs_group_rus_vmf_infantry_fireteam"]];
_group set [T_GROUP_inf_recon_patrol, [configFile >> "CfgGroups" >> "East" >> "rhs_faction_vmf" >> "rhs_group_rus_vmf_infantry_recon" >> "rhs_group_rus_vmf_infantry_recon_fireteam"]];
_group set [T_GROUP_inf_recon_sentry, [configFile >> "CfgGroups" >> "East" >> "rhs_faction_vmf" >> "rhs_group_rus_vmf_infantry_recon" >> "rhs_group_rus_vmf_infantry_recon_MANEUVER"]];
_group set [T_GROUP_inf_recon_squad, [configFile >> "CfgGroups" >> "East" >> "rhs_faction_vmf" >> "rhs_group_rus_vmf_infantry_recon" >> "rhs_group_rus_vmf_infantry_recon_squad"]];
_group set [T_GROUP_inf_recon_team, [configFile >> "CfgGroups" >> "East" >> "rhs_faction_vmf" >> "rhs_group_rus_vmf_infantry_recon" >> "rhs_group_rus_vmf_infantry_recon_fireteam"]];
_group set [T_GROUP_inf_sentry, [configFile >> "CfgGroups" >> "East" >> "rhs_faction_vmf" >> "rhs_group_rus_vmf_infantry" >> "rhs_group_rus_vmf_infantry_MANEUVER"]];
_group set [T_GROUP_inf_sniper_team, [configFile >> "CfgGroups" >> "East" >> "rhs_faction_vmf" >> "rhs_group_rus_vmf_infantry" >> "rhs_group_rus_vmf_infantry_section_marksman"]];



//==== Set arrays ====
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];


_array // End template

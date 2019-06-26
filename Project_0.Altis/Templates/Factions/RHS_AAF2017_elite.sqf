/*
Altis Armed Forces 2017 elite troops Template
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

//==== Infantry ====
_inf = [];
_inf set [T_INF_SIZE-1, nil]; 								//Make an array full of nil
_inf set [T_INF_DEFAULT, ["FNG_AAF_inf_rifleman"]];

_inf set [T_INF_SL, ["RHS_AAF2017_elite_SL"]];
_inf set [T_INF_TL, ["RHS_AAF2017_elite_TL"]];
_inf set [T_INF_officer, ["RHS_AAF2017_elite_officer"]];
_inf set [T_INF_GL, ["RHS_AAF2017_elite_grenadier"]];
_inf set [T_INF_rifleman, ["RHS_AAF2017_elite_rifleman"]];
_inf set [T_INF_marksman, ["RHS_AAF2017_elite_marksman"]]; //TODO add FAL to loadout- currently in RHS DEV
_inf set [T_INF_sniper, ["RHS_AAF2017_elite_sniper"]];
_inf set [T_INF_spotter, ["RHS_AAF2017_elite_spotter"]];
_inf set [T_INF_exp, ["RHS_AAF2017_elite_engineer"]];
_inf set [T_INF_ammo, ["RHS_AAF2017_elite_MG_assist.", "RHS_AAF2017_elite_AT_assist."]];
_inf set [T_INF_LAT, ["RHS_AAF2017_elite_rifleman"]];
_inf set [T_INF_AT, ["RHS_AAF2017_elite_AT"]];
_inf set [T_INF_AA, ["RHS_AAF2017_elite_AA"]];
_inf set [T_INF_LMG, ["RHS_AAF2017_elite_LMG"]];
_inf set [T_INF_HMG, ["RHS_AAF2017_elite_MG"]];
_inf set [T_INF_medic, ["RHS_AAF2017_elite_medic"]];
_inf set [T_INF_engineer, ["RHS_AAF2017_elite_engineer"]];
_inf set [T_INF_crew, ["RHS_AAF2017_elite_crew"]];
_inf set [T_INF_crew_heli, ["RHS_AAF2017_elite_helicrew"]];
_inf set [T_INF_pilot, ["RHS_AAF2017_elite_pilot"]];
_inf set [T_INF_pilot_heli, ["RHS_AAF2017_elite_helipilot"]];
_inf set [T_INF_survivor, ["RHS_AAF2017_elite_rifleman"]];
_inf set [T_INF_unarmed, ["RHS_AAF2017_elite_rifleman"]];

// Recon
_inf set [T_INF_recon_TL, ["RHS_AAF2017_recon_TL"]];
_inf set [T_INF_recon_rifleman, ["RHS_AAF2017_recon_rifleman"]];
_inf set [T_INF_recon_medic, ["RHS_AAF2017_recon_medic"]];
_inf set [T_INF_recon_exp, ["RHS_AAF2017_recon_expl.spec."]];
_inf set [T_INF_recon_LAT, ["RHS_AAF2017_recon_LAT"]];
_inf set [T_INF_recon_marksman, ["RHS_AAF2017_recon_sniper"]];
_inf set [T_INF_recon_JTAC, ["RHS_AAF2017_recon_JTAC"]];


// Divers, still vanilla
//_inf set [T_INF_diver_TL, ["B_diver_TL_F"]];
//_inf set [T_INF_diver_rifleman, ["B_diver_F"]];
//_inf set [T_INF_diver_exp, ["B_diver_exp_F"]];


//==== Vehicles ====
_veh = [];
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["FGN_AAF_M1025_unarmed"]];

_veh set [T_VEH_car_unarmed, ["FGN_AAF_M1025_unarmed", "FGN_AAF_M998_2D_Fulltop", "FGN_AAF_M998_4D_Fulltop"]];
_veh set [T_VEH_car_armed, ["FGN_AAF_M1025_M2", "FGN_AAF_M1025_MK19"]];

_veh set [T_VEH_MRAP_unarmed, ["FGN_AAF_Tigr_M", "FGN_AAF_Tigr"]];
_veh set [T_VEH_MRAP_HMG, ["FGN_AAF_Tigr_STS"]];
_veh set [T_VEH_MRAP_GMG, ["FGN_AAF_Tigr_STS"]];

_veh set [T_VEH_IFV, ["FGN_AAF_BMP3M_ERA"]];
_veh set [T_VEH_APC, ["rhsusf_m113d_usarmy_supply", "rhsusf_m113d_usarmy", "rhsusf_m113d_usarmy_MK19", "rhsusf_m113d_usarmy_unarmed"]]; //TODO - remove US army markings and iff pannels via garage
_veh set [T_VEH_MBT, ["rhs_t72bd_tv","rhs_t72be_tv"]]; //TODO - change color to "sand", add T-90M variants currently in RHS DEV
_veh set [T_VEH_MRLS, ["FGN_AAF_BM21"]];
//_veh set [T_VEH_SPA, ["TODO"]]; TODO add 2S1 from RHS DEV
_veh set [T_VEH_SPAA, ["FGN_AAF_Ural_ZU23", "rhs_zsu234_aa"]]; //TODO - chnage shilka color to "sand"

_veh set [T_VEH_stat_HMG_high, ["RHS_M2StaticMG_D"]];
_veh set [T_VEH_stat_GMG_high, ["RHS_MK19_TriPod_D"]];
_veh set [T_VEH_stat_HMG_low, ["RHS_M2StaticMG_MiniTripod_D"]];
_veh set [T_VEH_stat_GMG_low, ["RHS_MK19_TriPod_D"]];
_veh set [T_VEH_stat_AA, ["rhs_Igla_AA_pod_vmf"]];
_veh set [T_VEH_stat_AT, ["RHS_TOW_TriPod_D"]];

_veh set [T_VEH_stat_mortar_light, ["rhs_2b14_82mm_vmf"]];
_veh set [T_VEH_stat_mortar_heavy, ["rhs_D30_vmf"]];

//TODO remove HIDF markings from UH1 via garage
_veh set [T_VEH_heli_light, ["FGN_AAF_KA60_unarmed","rhs_uh1h_hidf"]];
_veh set [T_VEH_heli_heavy, ["FGN_AAF_KA60_dynamicLoadout","rhs_uh1h_hidf_gunship"]];
_veh set [T_VEH_heli_cargo, ["FGN_AAF_KA60_unarmed","rhs_uh1h_hidf_unarmed"]];
_veh set [T_VEH_heli_attack, ["rhsgref_mi24g_CAS"]];

_veh set [T_VEH_plane_attack, ["FGN_AAF_L159_dynamicLoadout"]];
_veh set [T_VEH_plane_fighter, ["FGN_AAF_L159_dynamicLoadout"]];
//_veh set [T_VEH_plane_cargo, ["TODO"]];
_veh set [T_VEH_plane_unarmed, ["rhsgred_hidf_cessna_o3a"]];
//_veh set [T_VEH_plane_VTOL, ["TODO"]];

_veh set [T_VEH_boat_unarmed, ["B_Boat_Transport_01_F", "I_C_Boat_Transport_02_F"]];
//_veh set [T_VEH_boat_armed, ["B_Boat_Armed_01_minigun_F"]];

_veh set [T_VEH_personal, ["B_Quadbike_01_F"]];

_veh set [T_VEH_truck_inf, ["FGN_AAF_Ural", "FGN_AAF_Ural_open", "FGN_AAF_Zamak_Open", "FGN_AAF_Zamak"]];
//_veh set [T_VEH_truck_cargo, ["TODO"]];
_veh set [T_VEH_truck_ammo, ["FGN_AAF_Zamak_Ammo"]];
_veh set [T_VEH_truck_repair, ["FGN_AAF_Ural_Repair","FGN_AAF_Zamak_Repair"]];
_veh set [T_VEH_truck_medical , ["FGN_AAF_Zamak_Medic"]];
_veh set [T_VEH_truck_fuel, ["FGN_AAF_Ural_Fuel","FGN_AAF_Zamak_Fuel"]];

//_veh set [T_VEH_submarine, ["B_SDV_01_F"]];


//==== Drones ====
_drone = [];
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


//==== Groups ====
_group = [];
_group set [T_GROUP_SIZE-1, nil];
_group set [T_GROUP_DEFAULT, [configFile >> "CfgGroups" >> "East" >> "rhs_faction_vmf" >> "rhs_group_rus_vmf_infantry" >> "rhs_group_rus_vmf_infantry_fireteam"]]; //TODO - Sparker needs to set this to AAF
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
_array set [T_GROUP, _group];


_array // End template

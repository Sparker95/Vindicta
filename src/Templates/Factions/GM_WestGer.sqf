/*
 __          __       _                     _____                                       
 \ \        / /      | |                   / ____|                                      
  \ \  /\  / /__  ___| |_ ___ _ __ _ __   | |  __  ___ _ __ _ __ ___   __ _ _ __  _   _ 
   \ \/  \/ / _ \/ __| __/ _ \ '__| '_ \  | | |_ |/ _ \ '__| '_ ` _ \ / _` | '_ \| | | |
    \  /\  /  __/\__ \ ||  __/ |  | | | | | |__| |  __/ |  | | | | | | (_| | | | | |_| |
     \/  \/ \___||___/\__\___|_|  |_| |_|  \_____|\___|_|  |_| |_| |_|\__,_|_| |_|\__, |
                                                                                   __/ |
                                                                                  |___/ 
*/

_array = [];

_array set [T_SIZE-1, nil];

_array set [T_NAME, "tGM_WestGer"]; 							// Template name + variable (not displayed)
_array set [T_DESCRIPTION, "Cold war era, western Germany."]; 	// Template display description
_array set [T_DISPLAY_NAME, "GM DLC - West Germany"]; 				// Template display name
_array set [T_FACTION, T_FACTION_military]; 					// Faction type: police, T_FACTION_military, T_FACTION_Police
_array set [T_REQUIRED_ADDONS, ["gm_core"]]; 					// Addons required to play this template


/* Infantry unit classes */
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_DEFAULT,  ["gm_ge_army_rifleman_g3a3_80_ols"]]; 	// = 0 Default if nothing found

_inf set [T_INF_SL, ["GM_WG_SL"]]; // = 1
_inf set [T_INF_TL, ["GM_WG_TL"]]; // = 2
_inf set [T_INF_officer, ["GM_WG_Officer"]]; // = 3
_inf set [T_INF_GL, ["GM_WG_GL"]]; // = 4
_inf set [T_INF_rifleman, ["GM_WG_Rifleman"]]; // = 5
_inf set [T_INF_marksman, ["GM_WG_Marksman"]]; // = 6
_inf set [T_INF_sniper, ["GM_WG_Sniper"]]; // = 7
_inf set [T_INF_spotter, ["GM_WG_Spotter"]]; // = 8
_inf set [T_INF_exp, ["GM_WG_Demolition"]]; // = 9
_inf set [T_INF_ammo, ["GM_WG_AmmoBearer"]]; // = 10
_inf set [T_INF_LAT, ["GM_WG_LAT"]]; // = 11
_inf set [T_INF_AT, ["GM_WG_AT"]]; // = 12
_inf set [T_INF_AA, ["GM_WG_AA"]]; // = 13
_inf set [T_INF_LMG, ["GM_WG_MG"]]; // = 14
_inf set [T_INF_HMG, ["GM_WG_MG"]]; // = 15
_inf set [T_INF_medic, ["GM_WG_Medic"]]; // = 16
_inf set [T_INF_engineer, ["GM_WG_Engineer"]]; // = 17 
_inf set [T_INF_crew, ["GM_WG_Crew"]]; // = 18
_inf set [T_INF_pilot, ["GM_WG_Pilot"]]; // = 19
_inf set [T_INF_unarmed, ["GM_WG_Unarmed"]]; // = 23
/* Recon unit classes */
_inf set [T_INF_recon_TL, ["GM_WG_SF_TL"]]; // = 24
_inf set [T_INF_recon_rifleman, ["GM_WG_SF_Rifleman"]]; // = 25
_inf set [T_INF_recon_medic, ["GM_WG_SF_Medic"]]; // = 26
_inf set [T_INF_recon_exp, ["GM_WG_SF_Demolition"]]; // = 27
_inf set [T_INF_recon_LAT, ["GM_WG_SF_LAT"]]; // = 28
_inf set [T_INF_recon_marksman, ["GM_WG_SF_Marksman"]]; // = 29
_inf set [T_INF_recon_JTAC, ["GM_WG_SF_Signaller"]]; // = 30

/* Vehicle classes */
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_DEFAULT, ["gm_ge_army_typ1200_cargo"]]; // = 0 Default if nothing found

_veh set [T_VEH_car_unarmed, ["gm_ge_army_iltis_cargo", "gm_ge_army_typ1200_cargo"]]; // = 1 – REQUIRED
_veh set [T_VEH_car_armed, ["gm_ge_army_iltis_mg3"]]; // = 2
_veh set [T_VEH_MRAP_unarmed, ["gm_ge_army_iltis_cargo" , "gm_ge_army_typ1200_cargo"]]; // = 3 – REQUIRED
_veh set [T_VEH_MRAP_HMG, ["gm_ge_army_iltis_mg3"]]; // = 4 – REQUIRED
_veh set [T_VEH_MRAP_GMG, ["gm_ge_army_iltis_milan"]]; // = 5 – REQUIRED
_veh set [T_VEH_IFV, ["gm_ge_army_fuchsa0_reconnaissance", "gm_ge_army_fuchsa0_engineer", "gm_ge_army_fuchsa0_command", "gm_ge_army_luchsa1", "gm_ge_army_luchsa2", "gm_ge_army_bpz2a0"]]; // = 6 – REQUIRED
_veh set [T_VEH_APC, ["gm_ge_army_m113a1g_apc", "gm_ge_army_m113a1g_apc_milan", "gm_ge_army_m113a1g_command"]]; // = 7 – REQUIRED
_veh set [T_VEH_MBT, ["gm_ge_army_Leopard1a1", "gm_ge_army_Leopard1a1a1", "gm_ge_army_Leopard1a1a2", "gm_ge_army_Leopard1a3", "gm_ge_army_Leopard1a3a1", "gm_ge_army_Leopard1a5"]]; // = 8 – REQUIRED
_veh set [T_VEH_SPAA, ["gm_ge_army_gepard1a1"]]; // = 11
_veh set [T_VEH_stat_HMG_high, ["gm_ge_army_mg3_aatripod"]]; // = 12 – REQUIRED
_veh set [T_VEH_stat_AA, ["gm_ge_army_mg3_aatripod"]]; // = 16
_veh set [T_VEH_stat_AT, ["gm_ge_army_milan_launcher_tripod"]]; // = 17
_veh set [T_VEH_stat_mortar_light, ["B_Mortar_01_F"]]; // = 18 - REQUIRED
_veh set [T_VEH_heli_light, ["gm_ge_army_bo105m_vbh", "gm_ge_army_bo105p1m_vbh", "gm_ge_army_bo105p1m_vbh_swooper"]]; // = 20
_veh set [T_VEH_heli_heavy, ["gm_ge_army_ch53g", "gm_ge_army_ch53gs"]]; // = 21
_veh set [T_VEH_heli_cargo, ["gm_ge_army_ch53g", "gm_ge_army_ch53gs"]]; // = 22
_veh set [T_VEH_heli_attack, ["gm_ge_army_bo105p_pah1", "gm_ge_army_bo105p_pah1a1"]]; // = 23
_veh set [T_VEH_plane_cargo, ["gm_ge_airforce_do28d2_medevac", "gm_ge_airforce_do28d2"]]; // = 26 – UNUSED
_veh set [T_VEH_plane_unarmed, ["gm_ge_airforce_do28d2"]]; // = 27 – UNUSED
_veh set [T_VEH_personal, ["gm_ge_army_bicycle_01_oli", "gm_ge_army_k125", "gm_ge_army_typ1200_cargo"]]; // = 31
_veh set [T_VEH_truck_inf, ["gm_ge_army_kat1_451_cargo", "gm_ge_army_u1300l_cargo"]]; // = 32 – REQUIRED
_veh set [T_VEH_truck_cargo, ["gm_ge_army_kat1_451_cargo", "gm_ge_army_kat1_451_container", "gm_ge_army_u1300l_container"]]; // = 33
_veh set [T_VEH_truck_ammo, ["gm_ge_army_kat1_451_reammo"]]; // = 34 – REQUIRED
_veh set [T_VEH_truck_repair, ["gm_ge_army_u1300l_repair", "gm_ge_army_bpz2a0", "gm_ge_army_fuchsa0_engineer"]]; // = 35
_veh set [T_VEH_truck_medical , ["gm_ge_army_u1300l_medic", "gm_ge_army_m113a1g_medic"]]; // = 36
_veh set [T_VEH_truck_fuel, ["gm_ge_army_kat1_451_refuel"]]; // = 37


/* Drone classes */
_drone = +(tDefault select T_DRONE);

/* Cargo classes */
_cargo = +(tDefault select T_CARGO);

/* Group templates */
_group = +(tDefault select T_GROUP);


/* Vehicle descriptions */
/*(T_NAMES select T_VEH) set [T_VEH_car_armed, "Armed Iltis"]; //						= 2 Car with any kind of mounted weapon
(T_NAMES select T_VEH) set [T_VEH_MRAP_unarmed, "Unarmed Iltis"]; //				= 3 MRAP
(T_NAMES select T_VEH) set [T_VEH_MRAP_HMG, "HMG Flatbed"]; //						= 4 MRAP with a mounted HMG gun
(T_NAMES select T_VEH) set [T_VEH_MRAP_GMG, "LAT Iltis"]; //						= 5 MRAP with a mounted GMG gun
(T_NAMES select T_VEH) set [T_VEH_SPAA, "Gepard 1a1"]; //		                    = 11 Self-Propelled Anti-Aircraft system
(T_NAMES select T_VEH) set [T_VEH_truck_inf, "Infantry Truck"]; //				= 32 Truck for infantry transport
(T_NAMES select T_VEH) set [T_VEH_truck_cargo, "Cargo Truck"]; //			= 33 Truck for general cargo transport
(T_NAMES select T_VEH) set [T_VEH_truck_ammo, "Ammo KAT1"]; //					= 34 Ammo truck
(T_NAMES select T_VEH) set [T_VEH_truck_repair, "Repair KAT1"]; //				= 35 Repair truck
(T_NAMES select T_VEH) set [T_VEH_truck_medical, "Medical KAT1"]; // 			= 36 Medical truck
(T_NAMES select T_VEH) set [T_VEH_truck_fuel, "Fuel KAT1"]; //					= 37 Fuel truck*/

/* Set arrays */
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];


_array /* END OF TEMPLATE */
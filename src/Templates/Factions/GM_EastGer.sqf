/*
E A S T E R N
G E R M A N Y
*/

_array = [];

_array set [T_SIZE-1, nil];

_array set [T_NAME, "tGM_EastGer"]; 							// Template name + variable (not displayed)
_array set [T_DESCRIPTION, "Cold war era, Eastern Germany."]; 	// Template display description
_array set [T_DISPLAY_NAME, "GM DLC - East Germany"]; 				// Template display name
_array set [T_FACTION, T_FACTION_military]; 					// Faction type: police, T_FACTION_military, T_FACTION_Police
_array set [T_REQUIRED_ADDONS, ["gm_core"]]; 					// Addons required to play this template


/* Infantry unit classes */
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default,  ["gm_gc_army_rifleman_mpiak74n_80_str"]];					//Default infantry if nothing is found

_inf set [T_INF_SL, ["GM_EG_SL"]]; // = 1
_inf set [T_INF_TL, ["gm_gc_army_squadleader_mpiak74n_80_str"]]; // = 2
_inf set [T_INF_officer, ["GM_EG_Officer"]]; // = 3
//_inf set [T_INF_GL, []]; // = 4
_inf set [T_INF_rifleman, ["gm_gc_army_rifleman_mpiak74n_80_str"]]; // = 5
_inf set [T_INF_marksman, ["gm_gc_army_marksman_svd_80_str"]]; // = 6
_inf set [T_INF_sniper, ["gm_gc_army_marksman_svd_80_str"]]; // = 7
_inf set [T_INF_spotter, ["GM_EG_Spotter"]]; // = 8
_inf set [T_INF_exp, ["gm_gc_army_demolition_mpiaks74n_80_str"]]; // = 9
_inf set [T_INF_ammo, ["GM_EG_Ammo"]]; // = 10
_inf set [T_INF_LAT, ["GM_EG_LAT"]]; // = 11 // LAT and AT have different ammo for RPG
_inf set [T_INF_AT, ["GM_EG_AT"]]; // = 12
_inf set [T_INF_AA, ["gm_gc_army_antiair_mpiak74n_9k32m_80_str"]]; // = 13
_inf set [T_INF_LMG, ["gm_gc_army_machinegunner_lmgrpk_80_str"]]; // = 14
_inf set [T_INF_HMG, ["gm_gc_army_machinegunner_pk_80_str"]]; // = 15
_inf set [T_INF_medic, ["GM_EG_Medic"]]; // = 16
_inf set [T_INF_engineer, ["GM_EG_Engineer"]]; // = 17 
_inf set [T_INF_crew, ["gm_gc_army_crew_mpiaks74nk_80_blk"]]; // = 18
_inf set [T_INF_crew_heli, ["gm_gc_airforce_pilot_pm_80_blu"]]; // = 19
_inf set [T_INF_pilot, ["gm_gc_airforce_pilot_pm_80_blu"]]; // = 20
_inf set [T_INF_pilot_heli, ["gm_gc_airforce_pilot_pm_80_blu"]]; // = 21
_inf set [T_INF_survivor, ["GM_EG_Unarmed"]]; // = 22
_inf set [T_INF_unarmed, ["GM_EG_Unarmed"]]; // = 23
/* Recon unit classes */
_inf set [T_INF_recon_TL, ["gm_gc_army_sf_squadleader_mpikms72_80_str"]]; // = 24
_inf set [T_INF_recon_rifleman, ["gm_gc_army_sf_rifleman_mpikms72_80_str"]]; // = 25
_inf set [T_INF_recon_medic, ["GM_EG_Medic"]]; // = 26 // TODO
_inf set [T_INF_recon_exp, ["gm_gc_army_sf_engineer_mpikms72_80_str"]]; // = 27
_inf set [T_INF_recon_LAT, ["gm_gc_army_sf_antitank_mpikms72_rpg7_80_str"]]; // = 28
_inf set [T_INF_recon_marksman, ["gm_gc_army_sf_marksman_svd_80_str"]]; // = 29
_inf set [T_INF_recon_JTAC, ["gm_gc_army_sf_rifleman_mpikms72_80_str"]]; // = 30 TODO

/* Vehicle classes */
_veh = []; _veh resize T_VEH_SIZE;
_veh set [T_VEH_DEFAULT, []]; // = 0 Default if nothing found

_veh set [T_VEH_car_unarmed, ["gm_gc_army_p601"]]; // = 1 – REQUIRED
//_veh set [T_VEH_car_armed, []]; // = 2
//_veh set [T_VEH_MRAP_unarmed, []]; // = 3 – REQUIRED
//_veh set [T_VEH_MRAP_HMG, []]; // = 4 – REQUIRED
//_veh set [T_VEH_MRAP_GMG, []]; // = 5 – REQUIRED
_veh set [T_VEH_IFV, ["gm_gc_army_bmp1sp2"]]; // = 6 – REQUIRED
_veh set [T_VEH_APC, ["gm_gc_army_btr60pb"]]; // = 7 – REQUIRED
_veh set [T_VEH_MBT, ["gm_gc_army_t55","gm_gc_army_t55a","gm_gc_army_t55ak","gm_gc_army_t55am2","gm_gc_army_t55am2b"]]; // = 8 – REQUIRED
_veh set [T_VEH_SPAA, ["gm_gc_army_zsu234v1"]]; // = 11
_veh set [T_VEH_stat_HMG_high, ["gm_ge_army_mg3_aatripod"]]; // = 12 – REQUIRED
//_veh set [T_VEH_stat_AA, []]; // = 16
//_veh set [T_VEH_stat_AT, []]; // = 17
_veh set [T_VEH_stat_mortar_light, ["B_Mortar_01_F"]]; // = 18 - REQUIRED
_veh set [T_VEH_heli_light, ["gm_gc_airforce_mi2p"]]; // = 20
//_veh set [T_VEH_heli_heavy, []]; // = 21
//_veh set [T_VEH_heli_cargo, []]; // = 22
_veh set [T_VEH_heli_attack, ["gm_gc_airforce_mi2urn", "gm_pl_airforce_mi2urp"]]; // = 23
//_veh set [T_VEH_plane_cargo, []]; // = 26 – UNUSED
_veh set [T_VEH_plane_unarmed, ["gm_gc_airforce_l410t"]]; // = 27 – UNUSED
_veh set [T_VEH_personal, ["gm_gc_army_bicycle_01_oli"]]; // = 31
_veh set [T_VEH_truck_inf, ["gm_gc_army_ural4320_cargo"]]; // = 32 – REQUIRED
_veh set [T_VEH_truck_cargo, ["gm_gc_army_ural44202"]]; // = 33
_veh set [T_VEH_truck_ammo, ["gm_gc_army_ural4320_reammo"]]; // = 34 – REQUIRED
_veh set [T_VEH_truck_repair, ["gm_gc_army_ural4320_repair"]]; // = 35
_veh set [T_VEH_truck_medical , ["gm_gc_army_ural375d_medic"]]; // = 36
_veh set [T_VEH_truck_fuel, ["gm_gc_army_ural375d_refuel"]]; // = 37


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
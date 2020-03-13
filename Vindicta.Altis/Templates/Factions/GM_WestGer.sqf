/*
West Germany Army templates for ARMA III
*/

_array = [];

_array set [T_SIZE-1, nil];					//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tGM_WestGer"];
_array set [T_DESCRIPTION, "West Germany Army, Global Mobilization - 80s."];
_array set [T_DISPLAY_NAME, "Cold War - West Germany"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, ["gm_core"]];


// ==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_DEFAULT, ["B_Soldier_F"]];	//Default infantry if nothing is found

_inf set [T_INF_SL, ["GM_WG_SL"]];
_inf set [T_INF_TL, ["GM_WG_SL"]];
_inf set [T_INF_officer, ["GM_WG_ArmyOfficer"]];
_inf set [T_INF_rifleman, ["GM_WG_Rifleman"]];
_inf set [T_INF_marksman, ["GM_WG_Marksman"]];
_inf set [T_INF_exp, ["GM_WG_Demolition"]];
_inf set [T_INF_ammo, ["GM_WG_AmmoBearer"]];
_inf set [T_INF_LAT, ["GM_WG_LAT"]];
_inf set [T_INF_AT, ["GM_WG_AT"]];
_inf set [T_INF_LMG, ["GM_WG_MG"]];
_inf set [T_INF_HMG, ["GM_WG_MG"]];
_inf set [T_INF_medic, ["GM_WG_Medic"]];
_inf set [T_INF_engineer, ["GM_WG_Engineer"]];
_inf set [T_INF_crew, ["GM_WG_Crew"]];
_inf set [T_INF_unarmed, ["GM_WG_Unarmed"]];

/*
_inf set [T_INF_crew_heli, [""]];
_inf set [T_INF_pilot, [""]];
_inf set [T_INF_pilot_heli, [""]];
_inf set [T_INF_survivor, [""]];
_inf set [T_INF_gl, [""]];
_inf set [T_INF_AA, [""]];
_inf set [T_INF_sniper, [""]];
_inf set [T_INF_spotter, ["GM_WG_Spotter"]];
*/


//	==== Recon ====
_inf set [T_INF_recon_TL, ["GM_WG_SF_TL"]];
_inf set [T_INF_recon_rifleman, ["GM_WG_SF_Rifleman"]];
_inf set [T_INF_recon_medic, ["GM_WG_SF_Medic"]];
_inf set [T_INF_recon_exp, ["GM_WG_SF_Demolition"]];
_inf set [T_INF_recon_LAT, ["GM_WG_SF_LAT"]];
_inf set [T_INF_recon_marksman, ["GM_WG_SF_Marksman"]];
_inf set [T_INF_recon_JTAC, ["GM_WG_SF_Signaller"]];


// ==== Vehicles ====
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["gm_ge_army_iltis_cargo"]];

_veh set [T_VEH_car_unarmed, ["gm_ge_army_iltis_cargo", "gm_ge_army_typ1200_cargo"]];
_veh set [T_VEH_car_armed, ["gm_ge_army_iltis_milan"]];

_veh set [T_VEH_MRAP_unarmed, ["gm_ge_army_iltis_cargo"]];
_veh set [T_VEH_MRAP_HMG, ["gm_ge_army_iltis_milan"]];
_veh set [T_VEH_MRAP_GMG, ["gm_ge_army_iltis_milan"]];

_veh set [T_VEH_IFV, ["gm_ge_army_fuchsa0_reconnaissance", "gm_ge_army_fuchsa0_engineer", "gm_ge_army_fuchsa0_command"]];
_veh set [T_VEH_APC, ["gm_ge_army_m113a1g_apc","gm_ge_army_m113a1g_apc_milan","gm_ge_army_m113a1g_command"]];
_veh set [T_VEH_MBT, ["gm_ge_army_Leopard1a5","gm_ge_army_Leopard1a1a2"]];

//_veh set [T_VEH_MRLS, [""]];
//_veh set [T_VEH_SPA, [""]];
_veh set [T_VEH_SPAA, ["gm_ge_army_gepard1a1"]];

//_veh set [T_VEH_stat_HMG_high, ["", ""]];
//_veh set [T_VEH_stat_GMG_high, [""]];

//_veh set [T_VEH_stat_HMG_low, [""]];
//_veh set [T_VEH_stat_GMG_low, [""]];

//_veh set [T_VEH_stat_AA, [""]];
//_veh set [T_VEH_stat_AT, [""]];

//_veh set [T_VEH_stat_mortar_light, [""]];
//_veh set [T_VEH_stat_mortar_heavy, [""]];
//_veh set [T_VEH_heli_light, [""]];
//_veh set [T_VEH_heli_heavy, [""]];
//_veh set [T_VEH_heli_cargo, [""]];
//_veh set [T_VEH_heli_attack, [""]];
//_veh set [T_VEH_plane_attack, [""]];
//_veh set [T_VEH_plane_fighter , [""]];
//_veh set [T_VEH_plane_cargo, [" "]];
//_veh set [T_VEH_plane_unarmed, [" "]];
//_veh set [T_VEH_plane_VTOL, [" "]];
//_veh set [T_VEH_boat_unarmed, [""]];
//_veh set [T_VEH_boat_armed, [""]];

_veh set [T_VEH_personal, ["gm_ge_army_k125"]];
_veh set [T_VEH_truck_inf, ["gm_ge_army_kat1_451_cargo", "gm_ge_army_u1300l_cargo"]];
_veh set [T_VEH_truck_cargo, ["gm_ge_army_kat1_451_cargo", "gm_ge_army_u1300l_cargo"]];
_veh set [T_VEH_truck_ammo, ["gm_ge_army_kat1_451_reammo"]];
_veh set [T_VEH_truck_repair, ["gm_ge_army_u1300l_repair"]];
_veh set [T_VEH_truck_medical, ["gm_ge_army_u1300l_medic"]];
_veh set [T_VEH_truck_fuel, ["gm_ge_army_kat1_451_refuel"]];

//_veh set [T_VEH_submarine, [""]];


// ==== Drones ====
_drone = [];
_drone set [T_DRONE_SIZE-1, nil];
/*
_veh set [T_DRONE_DEFAULT , [""]];

_drone set [T_DRONE_UGV_unarmed, [""]];
_drone set [T_DRONE_UGV_armed, [""]];
_drone set [T_DRONE_plane_attack, [""]];
_drone set [T_DRONE_plane_unarmed, ["B_UAV_02_dynamicLoadout_F"]];
_drone set [T_DRONE_heli_attack, [""]];
_drone set [T_DRONE_quadcopter, [""]];
drone set [T_DRONE_designator, [""]];
_drone set [T_DRONE_stat_HMG_low, [""]];
_drone set [T_DRONE_stat_GMG_low, [""]];
_drone set [T_DRONE_stat_AA, ["B_SAM_System_03_F"]];
*/

// ==== Cargo ====
_cargo = [];

// Note that we have increased their capacity through the addon, other boxes are going to have reduced capacity
_cargo set [T_CARGO_default,	["I_supplyCrate_F"]];
_cargo set [T_CARGO_box_small,	["Box_Syndicate_Ammo_F"]];
_cargo set [T_CARGO_box_medium,	["I_supplyCrate_F"]];
_cargo set [T_CARGO_box_big,	["B_CargoNet_01_ammo_F"]];

// ==== Groups ====
_group = [];
_group set [T_GROUP_SIZE-1, nil];
_group set [T_GROUP_DEFAULT, [[[T_INF, T_INF_TL], [T_INF, T_INF_LMG], [T_INF, T_INF_rifleman], [T_INF, T_INF_rifleman]]]];

_group set [T_GROUP_inf_sentry,			[[[T_INF, T_INF_TL], 		[T_INF, T_INF_rifleman]]]];
_group set [T_GROUP_inf_fire_team,		[[[T_INF, T_INF_TL], 		[T_INF, T_INF_LMG], 		[T_INF, T_INF_rifleman], [T_INF, T_INF_rifleman]]]];
_group set [T_GROUP_inf_AT_team,		[[[T_INF, T_INF_TL], 		[T_INF, T_INF_AT], 			[T_INF, T_INF_AT], [T_INF, T_INF_ammo]]]];
_group set [T_GROUP_inf_AA_team,		[[[T_INF, T_INF_TL], [T_INF, T_INF_AA], [T_INF, T_INF_AA], [T_INF, T_INF_ammo]]]];
_group set [T_GROUP_inf_rifle_squad,	[[[T_INF, T_INF_SL], 		[T_INF, T_INF_TL], 			[T_INF, T_INF_LMG], [T_INF, T_INF_rifleman], [T_INF, T_INF_LAT], [T_INF, T_INF_TL], [T_INF, T_INF_rifleman], [T_INF, T_INF_marksman], [T_INF, T_INF_medic]]]];
_group set [T_GROUP_inf_assault_squad,	[[[T_INF, T_INF_SL], 		[T_INF, T_INF_exp], 		[T_INF, T_INF_exp], [T_INF, T_INF_rifleman], [T_INF, T_INF_LMG], [T_INF, T_INF_rifleman], [T_INF, T_INF_LMG],[T_INF, T_INF_engineer], [T_INF, T_INF_engineer]]]];
_group set [T_GROUP_inf_weapons_squad,	[[[T_INF, T_INF_SL], 		[T_INF, T_INF_HMG], 		[T_INF, T_INF_ammo], [T_INF, T_INF_HMG], [T_INF, T_INF_ammo],	 [T_INF, T_INF_TL], [T_INF, T_INF_AT], [T_INF, T_INF_ammo], [T_INF, T_INF_LAT]]]];
_group set [T_GROUP_inf_sniper_team,	[[[T_INF, T_INF_sniper], 	[T_INF, T_INF_spotter]]]];
_group set [T_GROUP_inf_officer,		[[[T_INF, T_INF_officer], 	[T_INF, T_INF_rifleman], 	[T_INF, T_INF_rifleman]]]];
_group set [T_GROUP_inf_recon_patrol,	[[[T_INF, T_INF_recon_TL], [T_INF, T_INF_recon_rifleman], [T_INF, T_INF_recon_marksman], [T_INF, T_INF_recon_LAT]]]];
_group set [T_GROUP_inf_recon_sentry,	[[[T_INF, T_INF_recon_TL], [T_INF, T_INF_recon_LAT] ]]];
_group set [T_GROUP_inf_recon_squad,	[[[T_INF, T_INF_recon_TL], [T_INF, T_INF_recon_rifleman], [T_INF, T_INF_recon_marksman], [T_INF, T_INF_recon_medic], [T_INF, T_INF_recon_LAT],  [T_INF, T_INF_recon_JTAC], [T_INF, T_INF_recon_exp]]]];
_group set [T_GROUP_inf_recon_team,		[[[T_INF, T_INF_recon_TL], [T_INF, T_INF_recon_rifleman], [T_INF, T_INF_recon_marksman], [T_INF, T_INF_recon_LAT], [T_INF, T_INF_recon_exp], 	[T_INF, T_INF_recon_medic]]]];


// ==== Set arrays ====
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];


_array // End template

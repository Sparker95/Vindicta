/*
NATO templates for ARMA III
*/

_array = [];

_array set [T_SIZE-1, nil];									//Make an array having the size equal to the number of categories first

// Name, description, faction, addons, etc
_array set [T_NAME, "tDefault"];
_array set [T_DESCRIPTION, "Default template."];
_array set [T_DISPLAY_NAME, "Default"];
_array set [T_FACTION, T_FACTION_Military];
_array set [T_REQUIRED_ADDONS, ["A3_Characters_F"]];


//==== Infantry ====
_inf = [];
_inf resize T_INF_SIZE; 								//Make an array full of same class name
_inf = _inf apply {["B_Soldier_F"]};


//Recon

//Divers


//==== Vehicles ====

_veh = [];
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["B_MRAP_01_F"]];

_veh set [T_VEH_car_unarmed, ["B_MRAP_01_F"]];
_veh set [T_VEH_car_armed, ["B_MRAP_01_hmg_F"]];
_veh set [T_VEH_MRAP_unarmed, ["B_MRAP_01_F"]];
_veh set [T_VEH_MRAP_HMG, ["B_MRAP_01_hmg_F"]];
_veh set [T_VEH_MRAP_GMG, ["B_MRAP_01_gmg_F"]];
_veh set [T_VEH_IFV, ["B_APC_Wheeled_01_cannon_F"]]; //Marshal IFV
_veh set [T_VEH_APC, ["B_APC_Tracked_01_rcws_F"]]; //Panther
_veh set [T_VEH_MBT, ["B_MBT_01_cannon_F", "B_MBT_01_TUSK_F"]];
_veh set [T_VEH_MRLS, ["B_MBT_01_mlrs_F"]];
_veh set [T_VEH_SPA, ["B_MBT_01_arty_F"]];
_veh set [T_VEH_SPAA, ["B_APC_Tracked_01_AA_F"]];
_veh set [T_VEH_stat_HMG_high, ["B_HMG_01_high_F"]];
_veh set [T_VEH_stat_GMG_high, ["B_GMG_01_high_F"]];
_veh set [T_VEH_stat_HMG_low, ["B_HMG_01_F"]];
_veh set [T_VEH_stat_GMG_low, ["B_GMG_01_F"]];
_veh set [T_VEH_stat_AA, ["B_static_AA_F"]];
_veh set [T_VEH_stat_AT, ["B_static_AT_F"]];
_veh set [T_VEH_stat_mortar_light, ["B_Mortar_01_F"]];
//_veh set [T_VEH_stat_mortar_heavy, ["B_Mortar_01_F"]];
_veh set [T_VEH_heli_light, ["B_Heli_Light_01_F"]];
_veh set [T_VEH_heli_heavy, ["B_Heli_Transport_01_F"]];
_veh set [T_VEH_heli_cargo, ["B_Heli_Transport_03_unarmed_F"]];
_veh set [T_VEH_heli_attack, ["B_Heli_Attack_01_dynamicLoadout_F"]];
_veh set [T_VEH_plane_attack, ["B_Plane_CAS_01_dynamicLoadout_F"]];
_veh set [T_VEH_plane_fighter , ["B_Plane_Fighter_01_F"]];
//_veh set [T_VEH_plane_cargo, [" "]];
//_veh set [T_VEH_plane_unarmed, [" "]];
//_veh set [T_VEH_plane_VTOL, [" "]];
_veh set [T_VEH_boat_unarmed, ["B_Boat_Transport_01_F"]];
_veh set [T_VEH_boat_armed, ["B_Boat_Armed_01_minigun_F"]];
_veh set [T_VEH_personal, ["B_Quadbike_01_F"]];
_veh set [T_VEH_truck_inf, ["B_Truck_01_transport_F", "B_Truck_01_covered_F"]];
_veh set [T_VEH_truck_cargo, ["B_Truck_01_transport_F"]];
_veh set [T_VEH_truck_ammo, ["B_Truck_01_ammo_F"]];
_veh set [T_VEH_truck_repair, ["B_Truck_01_Repair_F"]];
_veh set [T_VEH_truck_medical , ["B_Truck_01_medical_F"]];
_veh set [T_VEH_truck_fuel, ["B_Truck_01_fuel_F"]];
_veh set [T_VEH_submarine, ["B_SDV_01_F"]];


//==== Drones ====
_drone = [];
_drone set [T_DRONE_SIZE-1, nil];
_veh set [T_DRONE_DEFAULT , ["B_UAV_01_F"]];

_drone set [T_DRONE_UGV_unarmed, ["B_UGV_01_F"]];
_drone set [T_DRONE_UGV_armed, ["B_UGV_01_rcws_F"]];
_drone set [T_DRONE_plane_attack, ["B_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_plane_unarmed, ["B_UAV_02_dynamicLoadout_F"]];
_drone set [T_DRONE_heli_attack, ["B_T_UAV_03_dynamicLoadout_F"]];
_drone set [T_DRONE_quadcopter, ["B_UAV_01_F"]];
_drone set [T_DRONE_designator, ["B_Static_Designator_01_F"]];
_drone set [T_DRONE_stat_HMG_low, ["B_HMG_01_A_F"]];
_drone set [T_DRONE_stat_GMG_low, ["B_GMG_01_A_F"]];
//_drone set [T_DRONE_stat_AA, ["B_SAM_System_03_F"]];

//==== Cargo ====
_cargo = [];

// Note that we have increased their capacity through the addon, other boxes are going to have reduced capacity
_cargo set [T_CARGO_default,	["I_supplyCrate_F"]];
_cargo set [T_CARGO_box_small,	["Box_Syndicate_Ammo_F"]];
_cargo set [T_CARGO_box_medium,	["I_supplyCrate_F"]];
_cargo set [T_CARGO_box_big,	["B_CargoNet_01_ammo_F"]];

//==== Groups ====
_group = [];
_group set [T_GROUP_SIZE-1, nil];
_group set [T_GROUP_DEFAULT, [[[T_INF, T_INF_TL], [T_INF, T_INF_LMG], [T_INF, T_INF_rifleman], [T_INF, T_INF_GL]]]];

_group set [T_GROUP_inf_sentry,			[[[T_INF, T_INF_TL], [T_INF, T_INF_rifleman]]]];
_group set [T_GROUP_inf_fire_team,		[[[T_INF, T_INF_TL], [T_INF, T_INF_LMG], [T_INF, T_INF_rifleman], [T_INF, T_INF_GL]]]];
_group set [T_GROUP_inf_AA_team,		[[[T_INF, T_INF_TL], [T_INF, T_INF_AA], [T_INF, T_INF_AA], [T_INF, T_INF_ammo]]]];
_group set [T_GROUP_inf_AT_team,		[[[T_INF, T_INF_TL], [T_INF, T_INF_AT], [T_INF, T_INF_AT], [T_INF, T_INF_ammo]]]];
_group set [T_GROUP_inf_rifle_squad,	[[[T_INF, T_INF_SL], 	[T_INF, T_INF_TL], [T_INF, T_INF_LMG], [T_INF, T_INF_GL], [T_INF, T_INF_LAT], 			[T_INF, T_INF_TL], [T_INF, T_INF_GL], [T_INF, T_INF_marksman], [T_INF, T_INF_medic]]]];
_group set [T_GROUP_inf_assault_squad,	[[[T_INF, T_INF_SL], 	[T_INF, T_INF_exp], [T_INF, T_INF_exp], [T_INF, T_INF_GL], [T_INF, T_INF_LMG], 			[T_INF, T_INF_GL], [T_INF, T_INF_LMG],[T_INF, T_INF_engineer], [T_INF, T_INF_engineer]]]];
_group set [T_GROUP_inf_weapons_squad,	[[[T_INF, T_INF_SL], 	[T_INF, T_INF_HMG], [T_INF, T_INF_ammo], [T_INF, T_INF_HMG], [T_INF, T_INF_ammo],		[T_INF, T_INF_TL], [T_INF, T_INF_AT], [T_INF, T_INF_ammo], [T_INF, T_INF_LAT]]]];
_group set [T_GROUP_inf_sniper_team,	[[[T_INF, T_INF_sniper], [T_INF, T_INF_spotter]]]];
_group set [T_GROUP_inf_officer,		[[[T_INF, T_INF_officer], [T_INF, T_INF_rifleman], [T_INF, T_INF_rifleman]]]];

_group set [T_GROUP_inf_recon_patrol,	[[[T_INF, T_INF_recon_TL], [T_INF, T_INF_recon_rifleman], [T_INF, T_INF_recon_marksman], [T_INF, T_INF_recon_LAT]]]];
_group set [T_GROUP_inf_recon_sentry,	[[[T_INF, T_INF_recon_TL], [T_INF, T_INF_recon_LAT] ]]];
_group set [T_GROUP_inf_recon_squad,	[[[T_INF, T_INF_recon_TL], [T_INF, T_INF_recon_rifleman], [T_INF, T_INF_recon_marksman], [T_INF, T_INF_recon_medic], [T_INF, T_INF_recon_LAT],  [T_INF, T_INF_recon_JTAC], [T_INF, T_INF_recon_exp]]]];
_group set [T_GROUP_inf_recon_team,		[[[T_INF, T_INF_recon_TL], [T_INF, T_INF_recon_rifleman], [T_INF, T_INF_recon_marksman], [T_INF, T_INF_recon_LAT], [T_INF, T_INF_recon_exp], [T_INF, T_INF_recon_medic]]]];

//==== Set arrays ====
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];


_array // End template

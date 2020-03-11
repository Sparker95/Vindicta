/*
███╗   ██╗ █████╗ ████████╗ ██████╗ 
████╗  ██║██╔══██╗╚══██╔══╝██╔═══██╗
██╔██╗ ██║███████║   ██║   ██║   ██║
██║╚██╗██║██╔══██║   ██║   ██║   ██║
██║ ╚████║██║  ██║   ██║   ╚██████╔╝
╚═╝  ╚═══╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ 
http://patorjk.com/software/taag/#p=testall&v=3&f=Big%20Money-nw&t=NATO                              
                         
Vindicta Faction Template. Use this template as the basis for your template.

Updated: March 2020 by Marvis

*/

_array = [];

_array set [T_SIZE-1, nil];									

_array set [T_NAME, "tNATO"]; // 							Template name + variable (not displayed)
_array set [T_DESCRIPTION, "Vanilla NATO."]; // 			Template display description
_array set [T_DISPLAY_NAME, "Arma 3 NATO"]; // 				Template display name
_array set [T_FACTION, T_FACTION_military]; // 				Faction type: police, T_FACTION_military, T_FACTION_Police
_array set [T_REQUIRED_ADDONS, ["A3_Characters_F"]]; // 	Addons required to play this template

/* 
	Infantry unit classes.

	Setting a new classname: 
	_inf set [T_INF_TL, ["CLASSNAME IN QUOTES"]];

	Example: 
	_inf set [T_INF_TL, ["B_Soldier_TL_F"]]; // 					= 2 Team leader

	1. 	DO NOT MODIFY the rest of the line. 
	2. 	Classname must not be empty ([]) or "". 
	3. 	If you comment out a class the default.sqf template classname will be used.
	4.	Do not comment out classes here. Leave the ones that are commented out.
	5.	Do not delete any lines.

	5. 	You can set identical units if a specific unit is not available.
		You can then edit the name of that unit further down in this template.	
*/
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_DEFAULT,  ["B_Soldier_F"]]; // = 0 Default if nothing found

_inf set [T_INF_SL, ["B_Soldier_SL_F"]]; // = 1
_inf set [T_INF_TL, ["B_Soldier_TL_F"]]; // = 2
_inf set [T_INF_officer, ["B_officer_F"]]; // = 3
_inf set [T_INF_GL, ["B_Soldier_GL_F"]]; // = 4
_inf set [T_INF_rifleman, ["B_Soldier_F"]]; // = 5
_inf set [T_INF_marksman, ["B_soldier_M_F"]]; // = 6
_inf set [T_INF_sniper, ["B_Sharpshooter_F"]]; // = 7
_inf set [T_INF_spotter, ["B_Soldier_lite_F"]]; // = 8
_inf set [T_INF_exp, ["B_soldier_exp_F"]]; // = 9
_inf set [T_INF_ammo, ["B_Soldier_A_F"]]; // = 10
_inf set [T_INF_LAT, ["B_soldier_LAT2_F"]]; // = 11
_inf set [T_INF_AT, ["B_soldier_LAT_F"]]; // = 12
_inf set [T_INF_AA, ["B_soldier_AA_F"]]; // = 13
_inf set [T_INF_LMG, ["B_soldier_AR_F"]]; // = 14
_inf set [T_INF_HMG, ["B_HeavyGunner_F"]]; // = 15
_inf set [T_INF_medic, ["B_medic_F"]]; // = 16
_inf set [T_INF_engineer, ["B_engineer_F"]]; // = 17 
_inf set [T_INF_crew, ["B_crew_F"]]; // = 18
_inf set [T_INF_crew_heli, ["B_helicrew_F"]]; // = 19
_inf set [T_INF_pilot, ["B_Fighter_Pilot_F"]]; // = 20
_inf set [T_INF_pilot_heli, ["B_Helipilot_F"]]; // = 21
_inf set [T_INF_survivor, ["B_Survivor_F"]]; // = 22
_inf set [T_INF_unarmed, ["B_Soldier_unarmed_F"]]; // = 23 – UNUSED

/* Recon unit classes */
_inf set [T_INF_recon_TL, ["B_recon_TL_F"]]; // = 24
_inf set [T_INF_recon_rifleman, ["B_recon_F"]]; // = 25
_inf set [T_INF_recon_medic, ["B_recon_medic_F"]]; // = 26
_inf set [T_INF_recon_exp, ["B_recon_exp_F"]]; // = 27
_inf set [T_INF_recon_LAT, ["B_recon_LAT_F"]]; // = 28
_inf set [T_INF_recon_marksman, ["B_recon_M_F"]]; // = 29
_inf set [T_INF_recon_JTAC, ["B_recon_JTAC_F"]]; // = 30

/* Diver unit classes */
_inf set [T_INF_diver_TL, ["B_diver_TL_F"]]; // = 31 – UNUSED
_inf set [T_INF_diver_rifleman, ["B_diver_F"]]; // = 32 – UNUSED
_inf set [T_INF_diver_exp, ["B_diver_exp_F"]]; // = 33 – UNUSED


/* Vehicle classes */
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["B_MRAP_01_F"]]; // = 0 Default if nothing found

_veh set [T_VEH_car_unarmed, ["B_MRAP_01_F"]]; // = 1 – REQUIRED
_veh set [T_VEH_car_armed, ["B_MRAP_01_hmg_F"]]; // = 2
_veh set [T_VEH_MRAP_unarmed, ["B_MRAP_01_F"]]; // = 3 – REQUIRED
_veh set [T_VEH_MRAP_HMG, ["B_MRAP_01_hmg_F"]]; // = 4 – REQUIRED
_veh set [T_VEH_MRAP_GMG, ["B_MRAP_01_gmg_F"]]; // = 5 – REQUIRED
_veh set [T_VEH_IFV, ["B_APC_Wheeled_01_cannon_F"]]; // = 6 – REQUIRED
_veh set [T_VEH_APC, ["B_APC_Tracked_01_rcws_F"]]; // = 7 – REQUIRED
_veh set [T_VEH_MBT, ["B_MBT_01_cannon_F", "B_MBT_01_TUSK_F"]]; // = 8 – REQUIRED
_veh set [T_VEH_MRLS, ["B_MBT_01_mlrs_F"]]; // = 9
_veh set [T_VEH_SPA, ["B_MBT_01_arty_F"]]; // = 10
_veh set [T_VEH_SPAA, ["B_APC_Tracked_01_AA_F"]]; // = 11
_veh set [T_VEH_stat_HMG_high, ["B_HMG_01_high_F"]]; // = 12 – REQUIRED
_veh set [T_VEH_stat_GMG_high, ["B_GMG_01_high_F"]]; // = 13 – REQUIRED
_veh set [T_VEH_stat_HMG_low, ["B_HMG_01_F"]]; // = 14
_veh set [T_VEH_stat_GMG_low, ["B_GMG_01_F"]]; // = 15
_veh set [T_VEH_stat_AA, ["B_static_AA_F"]]; // = 16
_veh set [T_VEH_stat_AT, ["B_static_AT_F"]]; // = 17
_veh set [T_VEH_stat_mortar_light, ["B_Mortar_01_F"]]; // = 18
//_veh set [T_VEH_stat_mortar_heavy, ["B_Mortar_01_F"]]; // = 19 – UNUSED
_veh set [T_VEH_heli_light, ["B_Heli_Light_01_F"]]; // = 20
_veh set [T_VEH_heli_heavy, ["B_Heli_Transport_01_F"]]; // = 21
_veh set [T_VEH_heli_cargo, ["B_Heli_Transport_03_unarmed_F"]]; // = 22
_veh set [T_VEH_heli_attack, ["B_Heli_Attack_01_dynamicLoadout_F"]]; // = 23
_veh set [T_VEH_plane_attack, ["B_Plane_CAS_01_dynamicLoadout_F"]]; // = 24
_veh set [T_VEH_plane_fighter , ["B_Plane_Fighter_01_F"]]; // = 25
//_veh set [T_VEH_plane_cargo, [" "]]; // = 26 – UNUSED
//_veh set [T_VEH_plane_unarmed, [" "]]; // = 27 – UNUSED
//_veh set [T_VEH_plane_VTOL, [" "]]; // = 28 – UNUSED
_veh set [T_VEH_boat_unarmed, ["B_Boat_Transport_01_F"]]; // = 29
_veh set [T_VEH_boat_armed, ["B_Boat_Armed_01_minigun_F"]]; // = 30
_veh set [T_VEH_personal, ["B_Quadbike_01_F"]]; // = 31
_veh set [T_VEH_truck_inf, ["B_Truck_01_transport_F", "B_Truck_01_covered_F"]]; // = 32 – REQUIRED
_veh set [T_VEH_truck_cargo, ["B_Truck_01_transport_F"]]; // = 33 – REQUIRED
_veh set [T_VEH_truck_ammo, ["B_Truck_01_ammo_F"]]; // = 34 – REQUIRED
_veh set [T_VEH_truck_repair, ["B_Truck_01_Repair_F"]]; // = 35 – REQUIRED
_veh set [T_VEH_truck_medical , ["B_Truck_01_medical_F"]]; // = 36 – REQUIRED
_veh set [T_VEH_truck_fuel, ["B_Truck_01_fuel_F"]]; // = 37 – REQUIRED
_veh set [T_VEH_submarine, ["B_SDV_01_F"]]; // = 38 – UNUSED


/* Drone classes */
_drone = +(tDefault select T_DRONE);
_drone set [T_DRONE_SIZE-1, nil];
_veh set [T_DRONE_DEFAULT , ["B_UAV_01_F"]];

_drone set [T_DRONE_UGV_unarmed, ["B_UGV_01_F"]]; // = 0
_drone set [T_DRONE_UGV_armed, ["B_UGV_01_rcws_F"]]; // = 1
_drone set [T_DRONE_plane_attack, ["B_UAV_02_dynamicLoadout_F"]]; // = 2
//_drone set [T_DRONE_plane_unarmed, ["B_UAV_02_dynamicLoadout_F"]]; // = 3 – UNUSED
_drone set [T_DRONE_heli_attack, ["B_T_UAV_03_dynamicLoadout_F"]]; // = 4
_drone set [T_DRONE_quadcopter, ["B_UAV_01_F"]]; // = 5
_drone set [T_DRONE_designator, ["B_Static_Designator_01_F"]]; // = 6
_drone set [T_DRONE_stat_HMG_low, ["B_HMG_01_A_F"]]; // = 7
_drone set [T_DRONE_stat_GMG_low, ["B_GMG_01_A_F"]]; // = 8
//_drone set [T_DRONE_stat_AA, ["B_SAM_System_03_F"]]; // = 9 – UNUSED

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

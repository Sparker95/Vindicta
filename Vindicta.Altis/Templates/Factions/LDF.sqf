/*
██╗     ██████╗ ███████╗
██║     ██╔══██╗██╔════╝
██║     ██║  ██║█████╗  
██║     ██║  ██║██╔══╝  
███████╗██████╔╝██║     
╚══════╝╚═════╝ ╚═╝ 
http://patorjk.com/software/taag/#p=display&v=3&f=ANSI%20Shadow&t=LDF

Updated: March 2020 by Marvis
*/

_array = [];

_array set [T_SIZE-1, nil];

_array set [T_NAME, "tLDF"]; // 																Template name + variable (not displayed)
_array set [T_DESCRIPTION, "Vanilla Livonian Defense Forces. Made by MatrikSky."]; // 			Template display description
_array set [T_DISPLAY_NAME, "Arma 3 LDF"]; // 													Template display name
_array set [T_FACTION, T_FACTION_Military]; // 													Faction type: police, T_FACTION_military, T_FACTION_Police
_array set [T_REQUIRED_ADDONS, ["A3_Characters_F"]]; // 										Addons required to play this template

/* Infantry unit classes */
_inf = [];
_inf resize T_INF_SIZE;
_inf set [T_INF_default,  ["I_E_Soldier_F"]];							//Default infantry if nothing is found

_inf set [T_INF_SL, ["I_E_Soldier_SL_F"]];
_inf set [T_INF_TL, ["I_E_Soldier_TL_F", "I_E_RadioOperator_F"]];
_inf set [T_INF_officer, ["I_E_Officer_F"]];
_inf set [T_INF_GL, ["I_E_Soldier_GL_F"]];
_inf set [T_INF_rifleman, ["I_E_Soldier_F", "I_E_Soldier_lite_F", "I_E_Soldier_Pathfinder_F"]];
_inf set [T_INF_marksman, ["I_E_Soldier_M_F"]];
_inf set [T_INF_sniper, ["Arma3_LDF_sniper"]];
_inf set [T_INF_spotter, ["Arma3_LDF_spotter"]];
_inf set [T_INF_exp, ["I_E_Soldier_exp_F", "I_E_soldier_Mine_F"]];
_inf set [T_INF_ammo, ["I_E_Soldier_A_F"]];
_inf set [T_INF_LAT, ["I_E_Soldier_LAT2_F"]];
_inf set [T_INF_AT, ["I_E_Soldier_LAT_F", "I_E_Soldier_AT_F"]];
_inf set [T_INF_AA, ["I_E_Soldier_AA_F"]];
_inf set [T_INF_LMG, ["I_E_Soldier_AR_F"]];
_inf set [T_INF_HMG, ["Arma3_LDF_HMG"]];
_inf set [T_INF_medic, ["I_E_Medic_F"]];
_inf set [T_INF_engineer, ["I_E_Engineer_F", "I_E_Soldier_Repair_F"]];
_inf set [T_INF_crew, ["I_E_Crew_F"]];
_inf set [T_INF_crew_heli, ["I_E_Helicrew_F"]];
_inf set [T_INF_pilot, ["Arma3_LDF_pilot"]];
_inf set [T_INF_pilot_heli, ["I_E_Helipilot_F"]];
_inf set [T_INF_survivor, ["I_E_Survivor_F"]];
_inf set [T_INF_unarmed, ["I_E_Soldier_unarmed_F"]];
/* Recon unit classes */
_inf set [T_INF_recon_TL, ["Arma3_LDF_recon_TL"]];
_inf set [T_INF_recon_rifleman, ["Arma3_LDF_recon_rifleman", "Arma3_LDF_recon_rifleman", "Arma3_LDF_recon_rifleman", "Arma3_LDF_recon_autorifleman"]];
_inf set [T_INF_recon_medic, ["Arma3_LDF_recon_medic"]];
_inf set [T_INF_recon_exp, ["Arma3_LDF_recon_explosives"]];
_inf set [T_INF_recon_LAT, ["Arma3_LDF_recon_LAT"]];
//_inf set [T_INF_recon_LMG, ["Arma3_LDF_recon_autorifleman"]]; // There is no T_INF_recon_LMG right now
_inf set [T_INF_recon_marksman, ["Arma3_LDF_recon_marksman"]];
_inf set [T_INF_recon_JTAC, ["Arma3_LDF_recon_JTAC"]];
/* Diver unit classes */
_inf set [T_INF_diver_TL, ["I_diver_TL_F"]];
_inf set [T_INF_diver_rifleman, ["I_diver_F"]];
_inf set [T_INF_diver_exp, ["I_diver_exp_F"]];


/* Vehicle classes */
_veh = +(tDefault select T_VEH);
_veh set [T_VEH_SIZE-1, nil];
_veh set [T_VEH_DEFAULT, ["I_E_Offroad_01_F"]];

_veh set [T_VEH_car_unarmed, ["I_E_Offroad_01_F", "I_E_Offroad_01_comms_F", "I_E_Offroad_01_covered_F"]];
_veh set [T_VEH_car_armed, ["I_G_Offroad_01_armed_F"]];

_veh set [T_VEH_MRAP_unarmed, ["B_T_MRAP_01_F"]];
_veh set [T_VEH_MRAP_HMG, ["B_T_MRAP_01_hmg_F"]];
_veh set [T_VEH_MRAP_GMG, ["B_T_MRAP_01_gmg_F"]];

_veh set [T_VEH_IFV, ["B_T_APC_Wheeled_01_cannon_F", "I_E_APC_tracked_03_cannon_F"]];
_veh set [T_VEH_APC, ["B_T_APC_Tracked_01_rcws_F"]];
_veh set [T_VEH_MBT, ["B_MBT_01_cannon_F", "B_MBT_01_TUSK_F"]];
_veh set [T_VEH_MRLS, ["I_E_Truck_02_MRL_F"]];
_veh set [T_VEH_SPA, ["B_MBT_01_arty_F"]];
_veh set [T_VEH_SPAA, ["B_APC_Tracked_01_AA_F"]];

_veh set [T_VEH_stat_HMG_high, ["I_E_HMG_01_high_F"]];
_veh set [T_VEH_stat_GMG_high, ["I_E_GMG_01_high_F"]];
_veh set [T_VEH_stat_HMG_low, ["I_E_HMG_01_F"]];
_veh set [T_VEH_stat_GMG_low, ["I_E_GMG_01_F"]];
_veh set [T_VEH_stat_AA, ["I_E_static_AA_F"]];
_veh set [T_VEH_stat_AT, ["I_E_static_AT_F", "ace_dragon_staticAssembled"]];
_veh set [T_VEH_stat_mortar_light, ["I_E_Mortar_01_F"]];
//_veh set [T_VEH_stat_mortar_heavy, ["I_Mortar_01_F"]];

_veh set [T_VEH_heli_light, ["B_Heli_Light_01_F"]];
_veh set [T_VEH_heli_heavy, ["I_E_Heli_light_03_unarmed_F", "B_Heli_Transport_01_F"]];
_veh set [T_VEH_heli_cargo, ["B_Heli_Transport_03_unarmed_F"]];
_veh set [T_VEH_heli_attack, ["I_E_Heli_light_03_dynamicLoadout_F", "B_Heli_Light_01_dynamicLoadout_F"]];

_veh set [T_VEH_plane_attack, ["B_Plane_CAS_01_dynamicLoadout_F"]];
_veh set [T_VEH_plane_fighter , ["B_Plane_Fighter_01_F"]];
//_veh set [T_VEH_plane_cargo, [""]];
//_veh set [T_VEH_plane_unarmed , [""]];
//_veh set [T_VEH_plane_VTOL, [""]];

_veh set [T_VEH_boat_unarmed, ["B_Boat_Transport_01_F"]];
_veh set [T_VEH_boat_armed, ["B_Boat_Armed_01_minigun_F"]];

_veh set [T_VEH_personal, ["I_E_Quadbike_01_F"]];

_veh set [T_VEH_truck_inf, ["I_E_Truck_02_F", "I_E_Truck_02_transport_F", "I_E_Van_02_transport_F"]];
_veh set [T_VEH_truck_cargo, ["I_E_Truck_02_F", "I_E_Van_02_vehicle_F"]];
_veh set [T_VEH_truck_ammo, ["I_E_Truck_02_ammo_F"]];
_veh set [T_VEH_truck_repair, ["I_E_Truck_02_box_F"]];
_veh set [T_VEH_truck_medical , ["I_E_Truck_02_medical_F", "I_E_Van_02_medevac_F"]];
_veh set [T_VEH_truck_fuel, ["I_E_Truck_02_fuel_F"]];

_veh set [T_VEH_submarine, ["I_SDV_01_F"]];


/* Drone classes */
_drone = +(tDefault select T_DRONE);
_drone set [T_DRONE_SIZE-1, nil];
_drone set [T_DRONE_DEFAULT, ["I_E_UGV_01_F"]];
_drone set [T_DRONE_UGV_unarmed, ["I_E_UGV_01_F"]];
_drone set [T_DRONE_UGV_armed, ["I_E_UGV_01_rcws_F"]];
//_drone set [T_DRONE_plane_attack, ["I_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_plane_unarmed, ["I_UAV_02_dynamicLoadout_F"]];
//_drone set [T_DRONE_heli_attack, ["I_UAV_02_dynamicLoadout_F"]];
_drone set [T_DRONE_quadcopter, ["I_E_UAV_01_F"]];
//_drone set [T_DRONE_designator, ["I_UAV_02_dynamicLoadout_F"]];
_drone set [T_DRONE_stat_HMG_low, ["I_E_HMG_01_A_F"]];
_drone set [T_DRONE_stat_GMG_low, ["I_E_GMG_01_A_F"]];
//_drone set [T_DRONE_stat_AA, ["I_E_SAM_System_03_F"]];

/* Cargo classes */
_cargo = +(tDefault select T_CARGO);

// Note that we have increased their capacity through the addon, other boxes are going to have reduced capacity
//_cargo set [T_CARGO_default,	["I_supplyCrate_F"]];
//_cargo set [T_CARGO_box_small,	["Box_Syndicate_Ammo_F"]];
//_cargo set [T_CARGO_box_medium,	["I_supplyCrate_F"]];
//_cargo set [T_CARGO_box_big,	["B_CargoNet_01_ammo_F"]];


/* Group templates */
_group = +(tDefault select T_GROUP);

//_group set [T_GROUP_SIZE-1, nil];
//_group set [T_GROUP_DEFAULT, [[[T_INF, T_INF_TL], [T_INF, T_INF_LMG], [T_INF, T_INF_rifleman], [T_INF, T_INF_GL]]]];

//_group set [T_GROUP_inf_sentry,			[[[T_INF, T_INF_TL], [T_INF, T_INF_rifleman]]]];
//_group set [T_GROUP_inf_fire_team,		[[[T_INF, T_INF_TL], [T_INF, T_INF_LMG], [T_INF, T_INF_rifleman], [T_INF, T_INF_GL]]]];
//_group set [T_GROUP_inf_AA_team,		[[[T_INF, T_INF_TL], [T_INF, T_INF_AA], [T_INF, T_INF_AA], [T_INF, T_INF_ammo]]]];
//_group set [T_GROUP_inf_AT_team,		[[[T_INF, T_INF_TL], [T_INF, T_INF_AT], [T_INF, T_INF_AT], [T_INF, T_INF_ammo]]]];
//_group set [T_GROUP_inf_rifle_squad,	[[[T_INF, T_INF_SL], 	[T_INF, T_INF_TL], [T_INF, T_INF_LMG], [T_INF, T_INF_GL], [T_INF, T_INF_LAT], 			[T_INF, T_INF_TL], [T_INF, T_INF_GL], [T_INF, T_INF_marksman], [T_INF, T_INF_medic]]]];
//_group set [T_GROUP_inf_assault_squad,	[[[T_INF, T_INF_SL], 	[T_INF, T_INF_exp], [T_INF, T_INF_exp], [T_INF, T_INF_GL], [T_INF, T_INF_LMG], 			[T_INF, T_INF_GL], [T_INF, T_INF_LMG],[T_INF, T_INF_engineer], [T_INF, T_INF_engineer]]]];
//_group set [T_GROUP_inf_weapons_squad,	[[[T_INF, T_INF_SL], 	[T_INF, T_INF_HMG], [T_INF, T_INF_ammo], [T_INF, T_INF_HMG], [T_INF, T_INF_ammo],		[T_INF, T_INF_TL], [T_INF, T_INF_AT], [T_INF, T_INF_ammo], [T_INF, T_INF_LAT]]]];
//_group set [T_GROUP_inf_sniper_team,	[[[T_INF, T_INF_sniper], [T_INF, T_INF_spotter]]]];
//_group set [T_GROUP_inf_officer,		[[[T_INF, T_INF_officer], [T_INF, T_INF_rifleman], [T_INF, T_INF_rifleman]]]];

//_group set [T_GROUP_inf_recon_patrol,	[[[T_INF, T_INF_recon_TL], [T_INF, T_INF_recon_rifleman], [T_INF, T_INF_recon_marksman], [T_INF, T_INF_recon_LAT]]]];
//_group set [T_GROUP_inf_recon_sentry,	[[[T_INF, T_INF_recon_TL], [T_INF, T_INF_recon_LAT] ]]];
//_group set [T_GROUP_inf_recon_squad,	[[[T_INF, T_INF_recon_TL], [T_INF, T_INF_recon_rifleman], [T_INF, T_INF_recon_marksman], [T_INF, T_INF_recon_medic], [T_INF, T_INF_recon_LAT],  [T_INF, T_INF_recon_JTAC], [T_INF, T_INF_recon_exp]]]];
//_group set [T_GROUP_inf_recon_team,		[[[T_INF, T_INF_recon_TL], [T_INF, T_INF_recon_rifleman], [T_INF, T_INF_recon_marksman], [T_INF, T_INF_recon_LAT], [T_INF, T_INF_recon_exp], [T_INF, T_INF_recon_medic]]]];



/* Unit descriptions */
//(T_NAMES select T_INF) set [T_INF_default, "Rifleman"]; //						= 0 Default if nothing found

//(T_NAMES select T_INF) set [T_INF_SL, "Squad Leader"]; //							= 1 Squad leader
//(T_NAMES select T_INF) set [T_INF_TL, "Team Leader"]; //							= 2 Team leader
//(T_NAMES select T_INF) set [T_INF_officer, "Officer"]; //							= 3 Officer
//(T_NAMES select T_INF) set [T_INF_GL, "Rifleman GL"]; //							= 4 GL soldier
//(T_NAMES select T_INF) set [T_INF_rifleman, "Rifleman"]; //						= 5 Basic rifleman
//(T_NAMES select T_INF) set [T_INF_marksman, "Marksman"]; //						= 6 Marksman
//(T_NAMES select T_INF) set [T_INF_sniper, "Sniper"]; //							= 7 Sniper
//(T_NAMES select T_INF) set [T_INF_spotter, "Spotter"]; //							= 8 Spotter
//(T_NAMES select T_INF) set [T_INF_exp, "Demo Specialist"]; //						= 9 Demo specialist
//(T_NAMES select T_INF) set [T_INF_ammo, "Ammo Bearer"]; //						= 10 Ammo bearer
//(T_NAMES select T_INF) set [T_INF_LAT, "Rifleman AT"]; //							= 11 Light Anti-Tank
//(T_NAMES select T_INF) set [T_INF_AT, "AT Specialist"]; //						= 12 Anti-Tank
//(T_NAMES select T_INF) set [T_INF_AA, "AA Specialist"]; //						= 13 Anti-Air
//(T_NAMES select T_INF) set [T_INF_LMG, "Light Machine Gunner"]; //				= 14 Light machinegunner
//(T_NAMES select T_INF) set [T_INF_HMG, "Heavy Machine Gunner"]; //				= 15 Heavy machinegunner
//(T_NAMES select T_INF) set [T_INF_medic, "Combat Medic"]; //						= 16 Combat Medic
//(T_NAMES select T_INF) set [T_INF_engineer, "Engineer"]; //						= 17 Engineer
//(T_NAMES select T_INF) set [T_INF_crew, "Crewman"]; //							= 18 Crewman
//(T_NAMES select T_INF) set [T_INF_crew_heli, "Heli. Crewman"]; //					= 19 Helicopter crew
//(T_NAMES select T_INF) set [T_INF_pilot, "Pilot"]; //								= 20 Plane pilot
//(T_NAMES select T_INF) set [T_INF_pilot_heli, "Heli. Pilot"]; //					= 21 Helicopter pilot
//(T_NAMES select T_INF) set [T_INF_survivor, "Survivor"]; //						= 22 Survivor
//(T_NAMES select T_INF) set [T_INF_unarmed, "Unarmed Man"]; //						= 23 Unarmed man

/* Recon unit descriptions */
//(T_NAMES select T_INF) set [T_INF_recon_TL, "Recon Team Leader"]; //				= 24 Recon team leader
//(T_NAMES select T_INF) set [T_INF_recon_rifleman, "Recon Rifleman"]; //			= 25 Recon scout
//(T_NAMES select T_INF) set [T_INF_recon_medic, "Recon Medic"]; //					= 26 Recon medic
//(T_NAMES select T_INF) set [T_INF_recon_exp, "Recon Explosive Specialist"]; //	= 27 Recon demo specialist
//(T_NAMES select T_INF) set [T_INF_recon_LAT, "Recon Rifleman AT"]; //				= 28 Recon light AT
//(T_NAMES select T_INF) set [T_INF_recon_marksman, "Recon Marksman"]; //			= 29 Recon marksman
//(T_NAMES select T_INF) set [T_INF_recon_JTAC, "Recon JTAC"]; //					= 30 Recon JTAC

/* Diver unit descriptions */
//(T_NAMES select T_INF) set [T_INF_diver_TL, "Diver Team Leader"]; //				= 31 Diver team leader
//(T_NAMES select T_INF) set [T_INF_diver_rifleman, "Diver Rifleman"]; //			= 32 Diver rifleman
//(T_NAMES select T_INF) set [T_INF_diver_exp, "Diver Explosive Specialist"]; //	= 33 Diver explosive specialist


/* Vehicle descriptions */
//(T_NAMES select T_VEH) set [T_VEH_default, "Unknown Vehicle"]; //					= 0 Default if nothing found

//(T_NAMES select T_VEH) set [T_VEH_car_unarmed, "Unarmed Car"]; //					= 1 Car like a Prowler or UAZ
//(T_NAMES select T_VEH) set [T_VEH_car_armed, "Armed Car"]; //						= 2 Car with any kind of mounted weapon
//(T_NAMES select T_VEH) set [T_VEH_MRAP_unarmed, "Unarmed MRAP"]; //				= 3 MRAP
//(T_NAMES select T_VEH) set [T_VEH_MRAP_HMG, "HMG MRAP"]; //						= 4 MRAP with a mounted HMG gun
//(T_NAMES select T_VEH) set [T_VEH_MRAP_GMG, "GMG MRAP"]; //						= 5 MRAP with a mounted GMG gun
//(T_NAMES select T_VEH) set [T_VEH_IFV, "IFV"]; //									= 6 Infantry fighting vehicle
//(T_NAMES select T_VEH) set [T_VEH_APC, "APC"]; //									= 7 Armored personnel carrier
//(T_NAMES select T_VEH) set [T_VEH_MBT, "MBT"]; //									= 8 Main Battle Tank
//(T_NAMES select T_VEH) set [T_VEH_MRLS, "MRLS"]; //								= 9 Multiple Rocket Launch System
//(T_NAMES select T_VEH) set [T_VEH_SPA, "Self-Propelled Artillery"]; //			= 10 Self-Propelled Artillery
//(T_NAMES select T_VEH) set [T_VEH_SPAA, "Self-Propelled Anti-Aircraft"]; //		= 11 Self-Propelled Anti-Aircraft system
//(T_NAMES select T_VEH) set [T_VEH_stat_HMG_high, "Static HMG"]; //				= 12 Static tripod Heavy Machine Gun (elevated)
//(T_NAMES select T_VEH) set [T_VEH_stat_GMG_high, "Static GMG"]; // 				= 13 Static tripod Grenade Machine Gun (elevated)
//(T_NAMES select T_VEH) set [T_VEH_stat_HMG_low, "Static HMG"]; //					= 14 Static tripod Heavy Machine Gun
//(T_NAMES select T_VEH) set [T_VEH_stat_GMG_low, "Static GMG"]; //					= 15 Static tripod Grenade Machine Gun
//(T_NAMES select T_VEH) set [T_VEH_stat_AA, "Static AA"]; //						= 16 Static AA, can be a gun or guided-missile launcher
//(T_NAMES select T_VEH) set [T_VEH_stat_AT, "Static AT"]; //						= 17 Static AT, e.g. a gun or ATGM
//(T_NAMES select T_VEH) set [T_VEH_stat_mortar_light, "Static Mortar"]; // 		= 18 Light mortar
//(T_NAMES select T_VEH) set [T_VEH_stat_mortar_heavy, "Static Heavy Mortar"]; // 	= 19 Heavy mortar, because RHS has some
//(T_NAMES select T_VEH) set [T_VEH_heli_light, "Light Helicopter"]; //				= 20 Light transport helicopter for infantry
//(T_NAMES select T_VEH) set [T_VEH_heli_heavy, "Heavy Helicopter"]; //				= 21 Heavy transport helicopter, both for cargo and infantry
//(T_NAMES select T_VEH) set [T_VEH_heli_cargo, "Cargo Helicopter"]; //				= 22 Heavy transport helicopter only for cargo
//(T_NAMES select T_VEH) set [T_VEH_heli_attack, "Attach Helicopter"]; //			= 23 Attack helicopter
//(T_NAMES select T_VEH) set [T_VEH_plane_attack, "Attack Plane"]; //				= 24 Attack plane, mainly for air-to-ground
//(T_NAMES select T_VEH) set [T_VEH_plane_fighter, "Figter Plane"]; // 				= 25 Fighter plane
//(T_NAMES select T_VEH) set [T_VEH_plane_cargo, "Cargo Plane"]; //					= 26 Cargo plane
//(T_NAMES select T_VEH) set [T_VEH_plane_unarmed, "Unarmed Plane"]; // 			= 27 Light unarmed plane like cessna
//(T_NAMES select T_VEH) set [T_VEH_plane_VTOL, "VTOL"]; //							= 28 VTOL
//(T_NAMES select T_VEH) set [T_VEH_boat_unarmed, "Unarmed Boat"]; //				= 29 Unarmed boat
//(T_NAMES select T_VEH) set [T_VEH_boat_armed, "Armed Boat"]; //					= 30 Armed boat
//(T_NAMES select T_VEH) set [T_VEH_personal, "Personal Vehicle"]; //				= 31 Quad bike or something for 1-2 men personal transport
//(T_NAMES select T_VEH) set [T_VEH_truck_inf, "Infantry Truck"]; //				= 32 Truck for infantry transport
//(T_NAMES select T_VEH) set [T_VEH_truck_cargo, "Cargo Truck"]; //					= 33 Truck for general cargo transport
//(T_NAMES select T_VEH) set [T_VEH_truck_ammo, "Ammo Truck"]; //					= 34 Ammo truck
//(T_NAMES select T_VEH) set [T_VEH_truck_repair, "Repair Truck"]; //				= 35 Repair truck
//(T_NAMES select T_VEH) set [T_VEH_truck_medical, "Medical Truck"]; // 			= 36 Medical truck
//(T_NAMES select T_VEH) set [T_VEH_truck_fuel, "Fuel Truck"]; //					= 37 Fuel truck
//(T_NAMES select T_VEH) set [T_VEH_submarine, "Submarine"]; //						= 38 Submarine


/* Drone descriptions */
//(T_NAMES select T_DRONE) set [T_DRONE_default, "Default drone"]; //					= 0 Default if nothing found
//(T_NAMES select T_DRONE) set [T_DRONE_UGV_unarmed, "Unarmed UGV"]; //					= 1 Any unarmed Unmanned Ground Vehicle
//(T_NAMES select T_DRONE) set [T_DRONE_UGV_armed, "Armed UGV"]; // 					= 2 Armed Unmanned Ground Vehicle
//(T_NAMES select T_DRONE) set [T_DRONE_plane_attack, "Armed UAV"]; // 					= 3 Attack drone plane, Unmanned Aerial Vehicle
//(T_NAMES select T_DRONE) set [T_DRONE_plane_unarmed, "Unarmed UAV"]; // 				= 4 Unarmed drone plane, Unmanned Aerial Vehicle
//(T_NAMES select T_DRONE) set [T_DRONE_heli_attack, "Unmanned Attack Helicopter"]; //  = 5 Attack helicopter
//(T_NAMES select T_DRONE) set [T_DRONE_quadcopter, "Unmanned Quadcopter"]; // 			= 6 Quad-rotor UAV
//(T_NAMES select T_DRONE) set [T_DRONE_designator, "Unmanned Designator"]; // 			= 7 Remote designator
//(T_NAMES select T_DRONE) set [T_DRONE_stat_HMG_low, "Unmanned Static HMG"]; // 		= 8 Static autonomous HMG
//(T_NAMES select T_DRONE) set [T_DRONE_stat_GMG_low, "Unmanned Static GMG"]; // 		= 9 Static autonomous GMG
//(T_NAMES select T_DRONE) set [T_DRONE_stat_AA, "Unmanned Static AA"]; // 				= 10 Static autonomous AA (?)


/* Cargo box descriptions */
//(T_NAMES select T_CARGO) set [T_CARGO_default, "Unknown Cargo Box"];
//(T_NAMES select T_CARGO) set [T_CARGO_box_small, "Small Cargo Box"];
//(T_NAMES select T_CARGO) set [T_CARGO_box_medium, "Medium Cargo Box"];
//(T_NAMES select T_CARGO) set [T_CARGO_box_big, "Big Cargo Box"];


/* Set arrays */
_array set [T_INF, _inf];
_array set [T_VEH, _veh];
_array set [T_DRONE, _drone];
_array set [T_CARGO, _cargo];
_array set [T_GROUP, _group];


_array /* END OF TEMPLATE */
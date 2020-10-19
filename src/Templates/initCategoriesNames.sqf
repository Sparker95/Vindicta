T_NAMES = [];


private _inf = [];
/* Main infantry unit descriptions */

_inf set [T_INF_default, "STR_ROSTER_RIFILEMAN"]; //						= 0 Default if nothing found

_inf set [T_INF_SL, "STR_ROSTER_SL"]; //							= 1 Squad leader
_inf set [T_INF_TL, "STR_ROSTER_TL"]; //							= 2 Team leader
_inf set [T_INF_officer, "STR_ROSTER_OFFICER"]; //							= 3 Officer
_inf set [T_INF_GL, "STR_ROSTER_GL"]; //							= 4 GL soldier
_inf set [T_INF_rifleman, "STR_ROSTER_RIFILEMAN"]; //						= 5 Basic rifleman
_inf set [T_INF_marksman, "STR_ROSTER_MARKSMAN"]; //						= 6 Marksman
_inf set [T_INF_sniper, "STR_ROSTER_SNIPER"]; //							= 7 Sniper
_inf set [T_INF_spotter, "STR_ROSTER_SPOTTER"]; //							= 8 Spotter
_inf set [T_INF_exp, "STR_ROSTER_EXPLOSIVE"]; //						= 9 Demo specialist
_inf set [T_INF_ammo, "STR_ROSTER_AMMO"]; //						= 10 Ammo bearer
_inf set [T_INF_LAT, "STR_ROSTER_LAT"]; //							= 11 Light Anti-Tank
_inf set [T_INF_AT, "STR_ROSTER_HAT"]; //						= 12 Anti-Tank
_inf set [T_INF_AA, "STR_ROSTER_AA"]; //						= 13 Anti-Air
_inf set [T_INF_LMG, "STR_ROSTER_LMG"]; //				= 14 Light machinegunner
_inf set [T_INF_HMG, "STR_ROSTER_HMG"]; //				= 15 Heavy machinegunner
_inf set [T_INF_medic, "STR_ROSTER_MEDIC"]; //						= 16 Combat Medic
_inf set [T_INF_engineer, "STR_ROSTER_ENGINEER"]; //						= 17 Engineer
_inf set [T_INF_crew, "STR_ROSTER_CREW"]; //							= 18 Crewman
_inf set [T_INF_crew_heli, "STR_ROSTER_HELICREW"]; //					= 19 Helicopter crew
_inf set [T_INF_pilot, "STR_ROSTER_PILOT"]; //								= 20 Plane pilot
_inf set [T_INF_pilot_heli, "STR_ROSTER_HELIPILOT"]; //					= 21 Helicopter pilot
_inf set [T_INF_survivor, "STR_ROSTER_SURVIVOR"]; //						= 22 Survivor
_inf set [T_INF_unarmed, "STR_ROSTER_MAN_UNARMED"]; //						= 23 Unarmed man

/* Recon unit descriptions */
_inf set [T_INF_recon_TL, "STR_ROSTER_R_TL"]; //				= 24 Recon team leader
_inf set [T_INF_recon_rifleman, "STR_ROSTER_R_RIFLEMAN"]; //			= 25 Recon scout
_inf set [T_INF_recon_medic, "STR_ROSTER_R_MEDIC"]; //					= 26 Recon medic
_inf set [T_INF_recon_exp, "STR_ROSTER_R_EXPLOSIVE"]; //	= 27 Recon demo specialist
_inf set [T_INF_recon_LAT, "STR_ROSTER_R_LAT"]; //				= 28 Recon light AT
_inf set [T_INF_recon_marksman, "STR_ROSTER_R_MARKSMAN"]; //			= 29 Recon marksman
_inf set [T_INF_recon_JTAC, "STR_ROSTER_R_JTAC"]; //					= 30 Recon JTAC

/* Diver unit descriptions */
_inf set [T_INF_diver_TL, "STR_ROSTER_D_TL"]; //				= 31 Diver team leader
_inf set [T_INF_diver_rifleman, "STR_ROSTER_D_RIFLEMAN"]; //			= 32 Diver rifleman
_inf set [T_INF_diver_exp, "STR_ROSTER_D_EXPLOSIVE"]; //	= 33 Diver explosive specialist

T_NAMES set [T_INF, _inf];

/* Vehicle descriptions */
private _veh = [];
_veh set [T_VEH_default, "STR_ROSTER_UNKOWN"]; //					= 0 Default if nothing found

_veh set [T_VEH_car_unarmed, "STR_ROSTER_CAR_UNARMED"]; //					= 1 Car like a Prowler or UAZ
_veh set [T_VEH_car_armed, "STR_ROSTER_ARMED_CAR"]; //						= 2 Car with any kind of mounted weapon
_veh set [T_VEH_MRAP_unarmed, "STR_ROSTER_MRAP_UNARMED"]; //				= 3 MRAP
_veh set [T_VEH_MRAP_HMG, "STR_ROSTER_HMG_MRAP"]; //						= 4 MRAP with a mounted HMG gun
_veh set [T_VEH_MRAP_GMG, "STR_ROSTER_GMG_MRAP"]; //						= 5 MRAP with a mounted GMG gun
_veh set [T_VEH_IFV, "STR_ROSTER_IFV"]; //									= 6 Infantry fighting vehicle
_veh set [T_VEH_APC, "STR_ROSTER_APC"]; //									= 7 Armored personnel carrier
_veh set [T_VEH_MBT, "STR_ROSTER_MBT"]; //									= 8 Main Battle Tank
_veh set [T_VEH_MRLS, "STR_ROSTER_MRLS"]; //								= 9 Multiple Rocket Launch System
_veh set [T_VEH_SPA, "STR_ROSTER_SPG"]; //			= 10 Self-Propelled Artillery
_veh set [T_VEH_SPAA, "STR_ROSTER_SPAA"]; //		= 11 Self-Propelled Anti-Aircraft system
_veh set [T_VEH_stat_HMG_high, "STR_ROSTER_STAT_HMG"]; //				= 12 Static tripod Heavy Machine Gun (elevated)
_veh set [T_VEH_stat_GMG_high, "STR_ROSTER_STAT_GMG"]; // 				= 13 Static tripod Grenade Machine Gun (elevated)
_veh set [T_VEH_stat_HMG_low, "STR_ROSTER_STAT_HMG"]; //					= 14 Static tripod Heavy Machine Gun
_veh set [T_VEH_stat_GMG_low, "STR_ROSTER_STAT_GMG"]; //					= 15 Static tripod Grenade Machine Gun
_veh set [T_VEH_stat_AA, "STR_ROSTER_STAT_AA"]; //						= 16 Static AA, can be a gun or guided-missile launcher
_veh set [T_VEH_stat_AT, "STR_ROSTER_STAT_AT"]; //						= 17 Static AT, e.g. a gun or ATGM
_veh set [T_VEH_stat_mortar_light, "STR_ROSTER_STAT_MORTAR"]; // 		= 18 Light mortar
_veh set [T_VEH_stat_mortar_heavy, "STR_ROSTER_STAT_MORTAR_HEAVY"]; // 	= 19 Heavy mortar, because RHS has some
_veh set [T_VEH_heli_light, "STR_ROSTER_HELI_LIGHT"]; //				= 20 Light transport helicopter for infantry
_veh set [T_VEH_heli_heavy, "STR_ROSTER_HELI_HEAVY"]; //				= 21 Heavy transport helicopter, both for cargo and infantry
_veh set [T_VEH_heli_cargo, "STR_ROSTER_HELI_CARGO"]; //				= 22 Heavy transport helicopter only for cargo
_veh set [T_VEH_heli_attack, "STR_ROSTER_HELI_ATTACK"]; //			= 23 Attack helicopter
_veh set [T_VEH_plane_attack, "STR_ROSTER_PLANE_ATTACK"]; //				= 24 Attack plane, mainly for air-to-ground
_veh set [T_VEH_plane_fighter, "STR_ROSTER_PLANE_FIGHTER"]; // 				= 25 Fighter plane
_veh set [T_VEH_plane_cargo, "STR_ROSTER_PLANE_CARGO"]; //					= 26 Cargo plane
_veh set [T_VEH_plane_unarmed, "STR_ROSTER_PLANE_UNARMED"]; // 			= 27 Light unarmed plane like cessna
_veh set [T_VEH_plane_VTOL, "STR_ROSTER_VTOL"]; //							= 28 VTOL
_veh set [T_VEH_boat_unarmed, "STR_ROSTER_BOAT_UNARMED"]; //				= 29 Unarmed boat
_veh set [T_VEH_boat_armed, "STR_ROSTER_BOAT_ARMED"]; //					= 30 Armed boat
_veh set [T_VEH_personal, "STR_ROSTER_PERSONAL"]; //				= 31 Quad bike or something for 1-2 men personal transport
_veh set [T_VEH_truck_inf, "STR_ROSTER_TRUCK_INF"]; //				= 32 Truck for infantry transport
_veh set [T_VEH_truck_cargo, "STR_ROSTER_TRUCK_CARGO"]; //					= 33 Truck for general cargo transport
_veh set [T_VEH_truck_ammo, "STR_ROSTER_TRUCK_AMMO"]; //					= 34 Ammo truck
_veh set [T_VEH_truck_repair, "STR_ROSTER_TRUCK_REPAIR"]; //				= 35 Repair truck
_veh set [T_VEH_truck_medical, "STR_ROSTER_TRUCK_MEDICAL"]; // 			= 36 Medical truck
_veh set [T_VEH_truck_fuel, "STR_ROSTER_TRUCK_FUEL"]; //					= 37 Fuel truck
_veh set [T_VEH_submarine, "STR_ROSTER_SUB"]; //						= 38 Submarine

T_NAMES set [T_VEH, _veh];

/* Drone descriptions */
_drone = [];
_drone set [T_DRONE_default, "STR_ROSTER_DRONE_DEFAULT"]; //					= 0 Default if nothing found
_drone set [T_DRONE_UGV_unarmed, "STR_ROSTER_UGV_UNARMED"]; //					= 1 Any unarmed Unmanned Ground Vehicle
_drone set [T_DRONE_UGV_armed, "STR_ROSTER_UGV_ARMED"]; // 					= 2 Armed Unmanned Ground Vehicle
_drone set [T_DRONE_plane_attack, "STR_ROSTER_UAV_ARMED"]; // 					= 3 Attack drone plane, Unmanned Aerial Vehicle
_drone set [T_DRONE_plane_unarmed, "STR_ROSTER_UAV_UNARMED"]; // 				= 4 Unarmed drone plane, Unmanned Aerial Vehicle
_drone set [T_DRONE_heli_attack, "STR_ROSTER_DRONE_HELI_ATTACK"]; //  = 5 Attack helicopter
_drone set [T_DRONE_quadcopter, "STR_ROSTER_QUADCOPTER"]; // 			= 6 Quad-rotor UAV
_drone set [T_DRONE_designator, "STR_ROSTER_DESIGNATOR"]; // 			= 7 Remote designator
_drone set [T_DRONE_stat_HMG_low, "STR_ROSTER_REMOTE_STAT_HMG"]; // 		= 8 Static autonomous HMG
_drone set [T_DRONE_stat_GMG_low, "STR_ROSTER_REMOTE_STAT_GMG"]; // 		= 9 Static autonomous GMG
_drone set [T_DRONE_stat_AA, "STR_ROSTER_REMOTE_STAT_AA"]; // 				= 10 Static autonomous AA (?)

T_NAMES set [T_DRONE, _drone];

/* Cargo box descriptions */
private _cargo = [];
_cargo set [T_CARGO_default, "STR_ROSTER_BOX_UNKNOWN"];
_cargo set [T_CARGO_box_small, "STR_ROSTER_BOX_SMALL"];
_cargo set [T_CARGO_box_medium, "STR_ROSTER_BOX_MEDIUM"];
_cargo set [T_CARGO_box_big, "STR_ROSTER_BOX_BIG"];

T_NAMES set [T_CARGO, _cargo];
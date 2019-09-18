/*
Templates could look like this:
[category_0, category_1, ...]

each category_X is an array of subcategories:
category_0 = [value_0, value_1, value_2, ...]

each value is an array of classnames for this category:
value_0 = [classname_0, classname_1, classname_2, etc];

So getting a random valaue from template should look like this:
selectRandom (template_NATO select T_INF select T_INF_rifleman)
OR it could be done through a get-function
Author: Sparker 08.2017
*/

T_SIZE = 5; //Number of categories in template
T_WEIGHTS_OFFSET = 5; //Number of categories in template

T_INF = 0;			//The ID of this category
T_INF_SIZE = 34;	//The size of this category

//Main infantry
T_INF_default		= 0; //Default if nothing found
T_INF_SL			= 1; //Squad leader
T_INF_TL			= 2; //Team leader
T_INF_officer		= 3; //Officer
T_INF_GL			= 4; //GL soldier
T_INF_rifleman		= 5; //Basic rifleman
T_INF_marksman		= 6; //Marksman
T_INF_sniper		= 7; //Sniper
T_INF_spotter		= 8; //Spotter
T_INF_exp			= 9; //Demo specialist
T_INF_ammo			= 10; //Ammo bearer
T_INF_LAT			= 11; //Light AT
T_INF_AT			= 12; //AT
T_INF_AA			= 13; //Anti-Air
T_INF_LMG			= 14; //Light machinegunner
T_INF_HMG			= 15; //Heavy machinegunner
T_INF_medic			= 16; //Medic
T_INF_engineer		= 17; //Engineer
T_INF_crew			= 18; //Crewman
T_INF_crew_heli		= 19; //Helicopter crew
T_INF_pilot			= 20; //Plane pilot
T_INF_pilot_heli	= 21; //Helicopter pilot
T_INF_survivor		= 22; //Survivor
T_INF_unarmed		= 23; //Unarmed man

//Recon
T_INF_recon_TL			= 24; //Recon team leader
T_INF_recon_rifleman	= 25; //Recon scout
T_INF_recon_medic		= 26; //Recon medic
T_INF_recon_exp			= 27; //Recon demo specialist
T_INF_recon_LAT			= 28; //Recon light AT
T_INF_recon_marksman	= 29; //Recon marksman
T_INF_recon_JTAC		= 30; //Recon JTAC

//Divers
T_INF_diver_TL			= 31; //Diver team leader
T_INF_diver_rifleman	= 32; //Diver rifleman
T_INF_diver_exp			= 33; //Diver explosive specialist

//Vehicles
T_VEH				= 1;
T_VEH_SIZE			= 39;

T_VEH_default		= 0;
//Ground vehicles
T_VEH_car_unarmed	= 1; //Car like Prowler or UAZ
T_VEH_car_armed		= 2;
T_VEH_MRAP_unarmed	= 3; //MRAP
T_VEH_MRAP_HMG		= 4;
T_VEH_MRAP_GMG		= 5;
T_VEH_IFV			= 6;
T_VEH_APC			= 7;
T_VEH_MBT			= 8; //Main Battle Tank
T_VEH_MRLS			= 9; //Multiple Rocket Launch System
T_VEH_SPA			= 10; //Self-Propelled Artillery
T_VEH_SPAA			= 11; //Self-Propelled Anti-Aircraft system
T_VEH_stat_HMG_high	= 12;
T_VEH_stat_GMG_high = 13;
T_VEH_stat_HMG_low	= 14;
T_VEH_stat_GMG_low	= 15;
T_VEH_stat_AA		= 16;
T_VEH_stat_AT		= 17;
T_VEH_stat_mortar_light = 18; //Light mortar
T_VEH_stat_mortar_heavy = 19; //Heavy mortar, because RHS has some
T_VEH_heli_light	= 20; //Light transport helicopter for infantry
T_VEH_heli_heavy	= 21; //Heavy transport helicopter, both for cargo and infantry
T_VEH_heli_cargo	= 22; //Heavy transport helicopter only for cargo
T_VEH_heli_attack	= 23; //Attack helicopter
T_VEH_plane_attack	= 24; //Attack plane, mainly for air-to-ground
T_VEH_plane_fighter = 25; //Fighter plane
T_VEH_plane_cargo	= 26; //Cargo plane
T_VEH_plane_unarmed = 27; //Light unarmed plane like cessna
T_VEH_plane_VTOL	= 28; //VTOL
T_VEH_boat_unarmed	= 29; //Unarmed boat
T_VEH_boat_armed	= 30; //Armed boat
T_VEH_personal		= 31; //Quad bike or something for 1-2 men personal transport
T_VEH_truck_inf		= 32; //Truck for infantry transport
T_VEH_truck_cargo	= 33; //Truck for general cargo transport
T_VEH_truck_ammo	= 34; //Ammo truck
T_VEH_truck_repair	= 35; //Repair truck
T_VEH_truck_medical = 36; //Medical truck
T_VEH_truck_fuel	= 37; //Fuel truck
T_VEH_submarine		= 38; //Submarine

//Vehicle subcategories sorted by required crew
T_VEH_need_basic_crew = [T_VEH_MRAP_HMG, T_VEH_MRAP_GMG, T_VEH_boat_armed]; //Vehicles that need a driver and a gunner, like MRAPs or boats
T_VEH_need_crew = [T_VEH_IFV, T_VEH_APC, T_VEH_MBT, T_VEH_MRLS, T_VEH_SPA, T_VEH_SPAA]; //Vehicles that need crew like T_INF_crew
T_VEH_need_heli_crew = [T_VEH_heli_light, T_VEH_heli_heavy, T_VEH_heli_cargo, T_VEH_heli_attack]; //Vehicles that need crew like T_INF_pilot_heli and T_INF_crew_heli
T_VEH_need_plane_crew = [T_VEH_plane_attack, T_VEH_plane_fighter, T_VEH_plane_cargo]; //Vehicles that need crew like T_INF_pilot
T_VEH_static = [T_VEH_stat_HMG_high, T_VEH_stat_GMG_high, T_VEH_stat_HMG_low, T_VEH_stat_GMG_low, T_VEH_stat_AA, T_VEH_stat_AT, T_VEH_stat_mortar_light, T_VEH_stat_mortar_heavy]; //Static weapons

// Vehicles which should be occupied when in combat
T_VEH_combat = T_VEH_need_basic_crew + T_VEH_need_crew;

// Ground vehicles with potential infantry transport capability
T_VEH_ground_infantry_cargo =
[
	T_VEH_car_unarmed,
	T_VEH_car_armed,
	T_VEH_MRAP_unarmed,
	T_VEH_MRAP_HMG,
	T_VEH_MRAP_GMG,
	T_VEH_IFV,
	T_VEH_APC,
	T_VEH_MBT,
	T_VEH_personal,
	T_VEH_truck_inf,
	T_VEH_truck_cargo
];

// Ground vehicles primarially for infantry transport
T_VEH_ground_transport =
[
	T_VEH_car_unarmed,
	T_VEH_MRAP_unarmed,
	T_VEH_MRAP_HMG,
	T_VEH_MRAP_GMG,
	T_VEH_IFV,
	T_VEH_APC,
	T_VEH_truck_inf
];

// Ground vehicles with combat capabilities
T_VEH_ground_combat =
[
	T_VEH_car_armed,
	T_VEH_MRAP_HMG,
	T_VEH_MRAP_GMG,
	T_VEH_IFV,
	T_VEH_APC,
	T_VEH_MBT
];

//Drones
T_DRONE = 2;
T_DRONE_SIZE = 11;

T_DRONE_default 		= 0; //A vacuum cleaner robot
T_DRONE_UGV_unarmed		= 1;
T_DRONE_UGV_armed		= 2;
T_DRONE_plane_attack	= 3; //Attack drone plane, mainly for air-to-ground
T_DRONE_plane_unarmed	= 4; //Unarmed drone plane
T_DRONE_heli_attack		= 5; //Attack helicopter
T_DRONE_quadcopter		= 6;
T_DRONE_designator		= 7; //Remote designator
T_DRONE_stat_HMG_low	= 8;
T_DRONE_stat_GMG_low	= 9;
T_DRONE_stat_AA			= 10;

//Cargo
T_CARGO = 3;
T_CARGO_SIZE = 4;

T_CARGO_default		= 0;
T_CARGO_box_small	= 1;
T_CARGO_box_medium	= 2;
T_CARGO_box_big		= 3;

//Groups
T_GROUP = 4;
T_GROUP_SIZE = 13;

T_GROUP_default				= 0; //Default group if group is not specified
T_GROUP_inf_AA_team			= 1;
T_GROUP_inf_AT_team			= 2;
T_GROUP_inf_rifle_squad		= 3;
T_GROUP_inf_assault_squad	= 4;
T_GROUP_inf_weapons_squad	= 5;
T_GROUP_inf_fire_team		= 6;
T_GROUP_inf_recon_patrol	= 7;
T_GROUP_inf_recon_sentry	= 8;
T_GROUP_inf_recon_squad		= 9;
T_GROUP_inf_recon_team		= 10;
T_GROUP_inf_sentry			= 11;
T_GROUP_inf_sniper_team		= 12;

//Subcategories sorted by their PLacement type
T_PL_tracked_wheeled = //Tracked and wheeled vehicles
[
	[T_VEH, T_VEH_car_unarmed],
	[T_VEH, T_VEH_car_armed],
	[T_VEH, T_VEH_MRAP_unarmed],
	[T_VEH, T_VEH_MRAP_HMG],
	[T_VEH, T_VEH_MRAP_GMG],
	[T_VEH, T_VEH_IFV],
	[T_VEH, T_VEH_APC],
	[T_VEH, T_VEH_MBT],
	[T_VEH, T_VEH_MRLS],
	[T_VEH, T_VEH_SPA],
	[T_VEH, T_VEH_SPAA],
	[T_VEH, T_VEH_personal],
	[T_VEH, T_VEH_truck_inf],
	[T_VEH, T_VEH_truck_cargo],
	[T_VEH, T_VEH_truck_ammo],
	[T_VEH, T_VEH_truck_repair],
	[T_VEH, T_VEH_truck_medical],
	[T_VEH, T_VEH_truck_fuel],
	[T_DRONE, T_DRONE_UGV_unarmed],
	[T_DRONE, T_DRONE_UGV_armed]
];

T_PL_HMG_GMG_high = //High GMGs and high HMGs
[
	[T_VEH, T_VEH_stat_HMG_high],
	[T_VEH, T_VEH_stat_GMG_high]
];

T_PL_HMG_GMG_low = //Low GMGs and low HMGs, including drones
[
	[T_VEH, T_VEH_stat_HMG_low],
	[T_VEH, T_VEH_stat_GMG_low],
	[T_DRONE, T_DRONE_stat_HMG_low],
	[T_DRONE, T_DRONE_stat_GMG_low]
];

T_PL_helicopters = //ALl helicopters including drones
[
	[T_VEH, T_VEH_heli_light],
	[T_VEH, T_VEH_heli_heavy],
	[T_VEH, T_VEH_heli_cargo],
	[T_VEH, T_VEH_heli_attack],
	[T_DRONE, T_DRONE_heli_attack]
];

T_PL_planes = //Planes including drones
[
	[T_VEH, T_VEH_plane_attack],
	[T_VEH, T_VEH_plane_fighter],
	[T_VEH, T_VEH_plane_cargo],
	[T_VEH, T_VEH_plane_unarmed],
	[T_VEH, T_VEH_plane_VTOL],
	[T_DRONE, T_DRONE_plane_attack],
	[T_DRONE, T_DRONE_plane_unarmed]
];

T_PL_inf_main = //Main infantry (excluding recon and divers)
[
	[T_INF, T_INF_SL],
	[T_INF, T_INF_TL],
	[T_INF, T_INF_officer],
	[T_INF, T_INF_GL],
	[T_INF, T_INF_rifleman],
	[T_INF, T_INF_marksman],
	[T_INF, T_INF_sniper],
	[T_INF, T_INF_spotter],
	[T_INF, T_INF_exp],
	[T_INF, T_INF_ammo],
	[T_INF, T_INF_LAT],
	[T_INF, T_INF_AT],
	[T_INF, T_INF_AA],
	[T_INF, T_INF_LMG],
	[T_INF, T_INF_HMG],
	[T_INF, T_INF_medic],
	[T_INF, T_INF_engineer],
	[T_INF, T_INF_crew],
	[T_INF, T_INF_crew_heli],
	[T_INF, T_INF_pilot],
	[T_INF, T_INF_pilot_heli],
	[T_INF, T_INF_survivor],
	[T_INF, T_INF_unarmed]
];

// Cargo boxes
T_PL_cargo =
[
	[T_CARGO, T_CARGO_box_small],
	[T_CARGO, T_CARGO_box_medium],
	[T_CARGO, T_CARGO_box_big]
];

//Transport vehicles (those that can potentially carry cargo)
T_canLoadCargo = [];

//All static units
T_static = [
	[T_VEH, T_VEH_stat_HMG_high],
	[T_VEH, T_VEH_stat_GMG_high],
	[T_VEH, T_VEH_stat_HMG_low],
	[T_VEH, T_VEH_stat_GMG_low],
	[T_VEH, T_VEH_stat_AA],
	[T_VEH, T_VEH_stat_AT],
	[T_VEH, T_VEH_stat_mortar_light],
	[T_VEH, T_VEH_stat_mortar_heavy],
	[T_DRONE, T_DRONE_stat_HMG_low],
	[T_DRONE, T_DRONE_stat_GMG_low],
	[T_DRONE, T_DRONE_stat_AA]
];


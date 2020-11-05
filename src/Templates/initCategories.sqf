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

// Declare a faction template category
#define T_DECLARE_CATEGORY(category, index, size) category = index; category##_SIZE = size; T_metadata set [index, [#category, []]]; (T_metadata select index) pushBack
// Declare an optional faction template entry
#define T_DECLARE_ENTRY_OPT(category, id, index) id = index; (T_metadata select category select 1) set [index, [#id, []] ];
// Declare a required faction template entry, see below for examples
#define T_DECLARE_ENTRY_REQ(category, id, index) id = index; (T_metadata select category select 1) set [index, [#id, []] ]; (T_metadata select category select 1 select index select 1) append
// Category metadata
// This contains extra info about a faction template category and its entries. 
// Currently it has the form:
//	[
//		[
//			"category name",
//			[
//				["entry name", [<factions this is required for>]], ...
//			]
//		], ...
//	]
T_metadata = [];

// Faction classes
T_FACTION_None 		= -1;
T_FACTION_Civ 		=  0;
T_FACTION_Guer 		=  1;
T_FACTION_Military 	=  2;
T_FACTION_Police 	=  3;

// Categories
T_DECLARE_CATEGORY(T_INF, 		0, 	34)		[T_FACTION_Civ, T_FACTION_Guer, T_FACTION_Military, T_FACTION_Police];
T_DECLARE_CATEGORY(T_VEH, 		1, 	39)		[T_FACTION_Civ, T_FACTION_Guer, T_FACTION_Military, T_FACTION_Police];
T_DECLARE_CATEGORY(T_DRONE, 	2, 	11)		[				T_FACTION_Guer, T_FACTION_Military					];
T_DECLARE_CATEGORY(T_CARGO, 	3, 	 4)		[				T_FACTION_Guer, T_FACTION_Military, T_FACTION_Police];
T_DECLARE_CATEGORY(T_GROUP, 	4, 	14)		[				T_FACTION_Guer, T_FACTION_Military, T_FACTION_Police];
T_NAME 						  = 5;			// Template name (internal)
T_INV 						  = 6;			// All inventory items sorted by categories. Initialized by server.
T_LOADOUT_GEAR 				  = 7;			// Unit loadout gear. Used to check which gear corresponds to which unit type. Initialized by server.
T_FACTION 					  = 8;			// Faction
T_REQUIRED_ADDONS 			  = 9;			// Addons which must be loaded on the server. It checks cfgPatches for these addons.
T_MISSING_ADDONS 			  = 10;			// Missing addons on the server. Initialized by server.
T_DESCRIPTION 				  = 11;			// A string with description to be shown in UI.
T_VALID 					  = 12;			// Bool. Initialized by server.
T_DISPLAY_NAME 				  = 13;			// Name to be shown in UI
T_DECLARE_CATEGORY(T_API, 		14,  2)		[];
T_DECLARE_CATEGORY(T_ARSENAL, 	15, 13)		[];	// T_FACTION_Civ ONLY
T_DECLARE_CATEGORY(T_UC, 		16, 10)		[];	// T_FACTION_Civ ONLY -- Undercover equipment and vehicle categories

T_SIZE = 17; //Number of categories in template
T_metadata resize T_SIZE;

// = = = = = = = = = = = = A P I = = = = = = = = = = = = =

T_DECLARE_ENTRY_OPT(T_API, T_API_fnc_init, 				 0);	// () -- Init function, run at campaign create and on each load
T_DECLARE_ENTRY_OPT(T_API, T_API_fnc_VEH_siren, 		 1);	// (handle vehicle, bool siren) -- Turn vehicle siren on and off, passing in the arma vehicle handle, and desired siren state

// = = = = = = = = = = A R S E N A L = = = = = = = = = = =

T_DECLARE_ENTRY_OPT(T_ARSENAL, T_ARSENAL_primary,		 0);
T_DECLARE_ENTRY_OPT(T_ARSENAL, T_ARSENAL_primary_items,	 1);
T_DECLARE_ENTRY_OPT(T_ARSENAL, T_ARSENAL_secondary,		 2);
T_DECLARE_ENTRY_OPT(T_ARSENAL, T_ARSENAL_secondary_items,3);
T_DECLARE_ENTRY_OPT(T_ARSENAL, T_ARSENAL_handgun,		 4);
T_DECLARE_ENTRY_OPT(T_ARSENAL, T_ARSENAL_handgun_items,	 5);
T_DECLARE_ENTRY_OPT(T_ARSENAL, T_ARSENAL_ammo,			 6);
T_DECLARE_ENTRY_OPT(T_ARSENAL, T_ARSENAL_items,			 7);
T_DECLARE_ENTRY_OPT(T_ARSENAL, T_ARSENAL_vests,			 8);
T_DECLARE_ENTRY_OPT(T_ARSENAL, T_ARSENAL_backpacks,		 9);
T_DECLARE_ENTRY_OPT(T_ARSENAL, T_ARSENAL_uniforms,		10);
T_DECLARE_ENTRY_OPT(T_ARSENAL, T_ARSENAL_facewear,		11);
T_DECLARE_ENTRY_OPT(T_ARSENAL, T_ARSENAL_headgear,		12);

// = = = = = = = = = U N D E R C O V E R = = = = = = = = =

T_DECLARE_ENTRY_OPT(T_UC, T_UC_uniforms,				 0);
T_DECLARE_ENTRY_OPT(T_UC, T_UC_headgear,				 1);
T_DECLARE_ENTRY_OPT(T_UC, T_UC_vests,					 2);
T_DECLARE_ENTRY_OPT(T_UC, T_UC_facewear,				 3);
T_DECLARE_ENTRY_OPT(T_UC, T_UC_backpacks,				 4);
T_DECLARE_ENTRY_OPT(T_UC, T_UC_ghillies,				 5);
T_DECLARE_ENTRY_OPT(T_UC, T_UC_items,					 6);
T_DECLARE_ENTRY_OPT(T_UC, T_UC_weapons,					 7);
T_DECLARE_ENTRY_OPT(T_UC, T_UC_suspweapons,				 8);
T_DECLARE_ENTRY_OPT(T_UC, T_UC_civVehs,					 9);

// = = = = = = = = = = I N F A N T R Y = = = = = = = = = = 
 
//Main infantry
//				Category   Entry						Index	Factions this entry is required for, if any
T_DECLARE_ENTRY_REQ(T_INF, T_INF_default, 				 0)		[T_FACTION_Civ, T_FACTION_Guer, T_FACTION_Military, T_FACTION_Police];	//Default if nothing found
T_DECLARE_ENTRY_OPT(T_INF, T_INF_SL, 					 1);	/*Squad leader*/
T_DECLARE_ENTRY_OPT(T_INF, T_INF_TL, 					 2);	//Team leader
T_DECLARE_ENTRY_REQ(T_INF, T_INF_officer, 				 3)		[T_FACTION_Guer, T_FACTION_Military, T_FACTION_Police]; //Officer
T_DECLARE_ENTRY_OPT(T_INF, T_INF_GL, 					 4);	//GL soldier
T_DECLARE_ENTRY_REQ(T_INF, T_INF_rifleman, 				 5)		[T_FACTION_Guer, T_FACTION_Military]; //Basic rifleman
T_DECLARE_ENTRY_REQ(T_INF, T_INF_marksman, 				 6)		[T_FACTION_Guer, T_FACTION_Military]; //Marksman
T_DECLARE_ENTRY_OPT(T_INF, T_INF_sniper, 				 7);	//Sniper
T_DECLARE_ENTRY_OPT(T_INF, T_INF_spotter, 				 8);	//Spotter
T_DECLARE_ENTRY_REQ(T_INF, T_INF_exp, 					 9)		[T_FACTION_Civ]; //Demo specialist
T_DECLARE_ENTRY_OPT(T_INF, T_INF_ammo, 					10);	//Ammo bearer
T_DECLARE_ENTRY_OPT(T_INF, T_INF_LAT, 					11);	//Light AT
T_DECLARE_ENTRY_REQ(T_INF, T_INF_AT, 					12)		[T_FACTION_Guer, T_FACTION_Military]; //AT
T_DECLARE_ENTRY_REQ(T_INF, T_INF_AA, 					13)		[T_FACTION_Guer, T_FACTION_Military]; //Anti-Air
T_DECLARE_ENTRY_REQ(T_INF, T_INF_LMG, 					14)		[T_FACTION_Guer, T_FACTION_Military]; //Light machinegunner
T_DECLARE_ENTRY_REQ(T_INF, T_INF_HMG, 					15)		[T_FACTION_Guer, T_FACTION_Military]; //Heavy machinegunner
T_DECLARE_ENTRY_REQ(T_INF, T_INF_medic, 				16)		[T_FACTION_Guer, T_FACTION_Military]; //Medic
T_DECLARE_ENTRY_REQ(T_INF, T_INF_engineer, 				17)		[T_FACTION_Guer, T_FACTION_Military]; //Engineer
T_DECLARE_ENTRY_REQ(T_INF, T_INF_crew, 					18)		[T_FACTION_Guer, T_FACTION_Military]; //Crewman
T_DECLARE_ENTRY_OPT(T_INF, T_INF_crew_heli, 			19);	//Helicopter crew
T_DECLARE_ENTRY_OPT(T_INF, T_INF_pilot, 				20);	//Plane pilot
T_DECLARE_ENTRY_OPT(T_INF, T_INF_pilot_heli, 			21);	//Helicopter pilot
T_DECLARE_ENTRY_REQ(T_INF, T_INF_survivor, 				22)		[T_FACTION_Civ]; //Survivor
T_DECLARE_ENTRY_REQ(T_INF, T_INF_unarmed, 				23)		[T_FACTION_Civ]; //Unarmed man

//Recon
T_DECLARE_ENTRY_OPT(T_INF, T_INF_recon_TL, 				24);	//Recon team leader
T_DECLARE_ENTRY_OPT(T_INF, T_INF_recon_rifleman,		25);	//Recon scout
T_DECLARE_ENTRY_OPT(T_INF, T_INF_recon_medic,			26);	//Recon medic
T_DECLARE_ENTRY_OPT(T_INF, T_INF_recon_exp,				27);	//Recon demo specialist
T_DECLARE_ENTRY_OPT(T_INF, T_INF_recon_LAT,				28);	//Recon light AT
T_DECLARE_ENTRY_OPT(T_INF, T_INF_recon_marksman,		29);	//Recon marksman
T_DECLARE_ENTRY_OPT(T_INF, T_INF_recon_JTAC,			30);	//Recon JTAC

//Divers
T_DECLARE_ENTRY_OPT(T_INF, T_INF_diver_TL,				31);	//Diver team leader
T_DECLARE_ENTRY_OPT(T_INF, T_INF_diver_rifleman,		32);	//Diver rifleman
T_DECLARE_ENTRY_OPT(T_INF, T_INF_diver_exp,				33);	//Diver explosive specialist




// = = = = = = = = = = V E H I C L E S = = = = = = = = = = 

//Vehicles

T_DECLARE_ENTRY_REQ(T_VEH, T_VEH_default,				 0)		[T_FACTION_Civ, T_FACTION_Guer, T_FACTION_Military, T_FACTION_Police];
//Ground vehicles
T_DECLARE_ENTRY_REQ(T_VEH, T_VEH_car_unarmed,			 1)		[T_FACTION_Guer, T_FACTION_Military, T_FACTION_Police]; //Car like Prowler or UAZ
T_DECLARE_ENTRY_OPT(T_VEH, T_VEH_car_armed,				 2);
T_DECLARE_ENTRY_REQ(T_VEH, T_VEH_MRAP_unarmed,			 3)		[T_FACTION_Guer, T_FACTION_Military]; //MRAP
T_DECLARE_ENTRY_REQ(T_VEH, T_VEH_MRAP_HMG,				 4)		[T_FACTION_Guer, T_FACTION_Military];
T_DECLARE_ENTRY_OPT(T_VEH, T_VEH_MRAP_GMG,				 5);
T_DECLARE_ENTRY_REQ(T_VEH, T_VEH_IFV,					 6)		[T_FACTION_Guer, T_FACTION_Military];
T_DECLARE_ENTRY_REQ(T_VEH, T_VEH_APC,					 7)		[T_FACTION_Guer, T_FACTION_Military];
T_DECLARE_ENTRY_REQ(T_VEH, T_VEH_MBT,					 8)		[T_FACTION_Guer, T_FACTION_Military]; //Main Battle Tank
T_DECLARE_ENTRY_OPT(T_VEH, T_VEH_MRLS,					 9);	//Multiple Rocket Launch System
T_DECLARE_ENTRY_OPT(T_VEH, T_VEH_SPA,					10);	//Self-Propelled Artillery
T_DECLARE_ENTRY_OPT(T_VEH, T_VEH_SPAA,					11);	//Self-Propelled Anti-Aircraft system
T_DECLARE_ENTRY_OPT(T_VEH, T_VEH_stat_HMG_high,			12);
T_DECLARE_ENTRY_OPT(T_VEH, T_VEH_stat_GMG_high,			13);
T_DECLARE_ENTRY_OPT(T_VEH, T_VEH_stat_HMG_low,			14);
T_DECLARE_ENTRY_OPT(T_VEH, T_VEH_stat_GMG_low,			15);
T_DECLARE_ENTRY_OPT(T_VEH, T_VEH_stat_AA,				16);
T_DECLARE_ENTRY_OPT(T_VEH, T_VEH_stat_AT,				17);
T_DECLARE_ENTRY_OPT(T_VEH, T_VEH_stat_mortar_light, 	18);	//Light mortar
T_DECLARE_ENTRY_OPT(T_VEH, T_VEH_stat_mortar_heavy, 	19);	//Heavy mortar, because RHS has some
T_DECLARE_ENTRY_OPT(T_VEH, T_VEH_heli_light,			20);	//Light transport helicopter for infantry
T_DECLARE_ENTRY_OPT(T_VEH, T_VEH_heli_heavy,			21);	//Heavy transport helicopter, both for cargo and infantry
T_DECLARE_ENTRY_OPT(T_VEH, T_VEH_heli_cargo,			22);	//Heavy transport helicopter only for cargo
T_DECLARE_ENTRY_OPT(T_VEH, T_VEH_heli_attack, 			23);	//Attack helicopter
T_DECLARE_ENTRY_OPT(T_VEH, T_VEH_plane_attack,			24);	//Attack plane, mainly for air-to-ground
T_DECLARE_ENTRY_OPT(T_VEH, T_VEH_plane_fighter,			25);	//Fighter plane
T_DECLARE_ENTRY_OPT(T_VEH, T_VEH_plane_cargo,			26);	//Cargo plane
T_DECLARE_ENTRY_OPT(T_VEH, T_VEH_plane_unarmed,			27);	//Light unarmed plane like cessna
T_DECLARE_ENTRY_OPT(T_VEH, T_VEH_plane_VTOL,			28);	//VTOL
T_DECLARE_ENTRY_REQ(T_VEH, T_VEH_boat_unarmed,			29) [T_FACTION_Civ];	//Unarmed boat
T_DECLARE_ENTRY_OPT(T_VEH, T_VEH_boat_armed,			30);	//Armed boat
T_DECLARE_ENTRY_OPT(T_VEH, T_VEH_personal,				31);	//Quad bike or something for 1-2 men personal transport
T_DECLARE_ENTRY_REQ(T_VEH, T_VEH_truck_inf,				32)		[T_FACTION_Guer, T_FACTION_Military]; //Truck for infantry transport
T_DECLARE_ENTRY_REQ(T_VEH, T_VEH_truck_cargo,			33)		[T_FACTION_Guer, T_FACTION_Military]; //Truck for general cargo transport
T_DECLARE_ENTRY_REQ(T_VEH, T_VEH_truck_ammo,			34)		[T_FACTION_Guer, T_FACTION_Military]; //Ammo truck
T_DECLARE_ENTRY_REQ(T_VEH, T_VEH_truck_repair,			35)		[T_FACTION_Guer, T_FACTION_Military]; //Repair truck
T_DECLARE_ENTRY_REQ(T_VEH, T_VEH_truck_medical,			36)		[T_FACTION_Guer, T_FACTION_Military]; //Medical truck
T_DECLARE_ENTRY_REQ(T_VEH, T_VEH_truck_fuel,			37)		[T_FACTION_Guer, T_FACTION_Military]; //Fuel truck
T_DECLARE_ENTRY_OPT(T_VEH, T_VEH_submarine,				38);	//Submarine

// Air vehicles
T_VEH_heli				= [T_VEH_heli_light, T_VEH_heli_heavy, T_VEH_heli_cargo, T_VEH_heli_attack];
T_VEH_plane				= [T_VEH_plane_attack, T_VEH_plane_fighter, T_VEH_plane_cargo, T_VEH_plane_unarmed, T_VEH_plane_VTOL];
T_VEH_air				= T_VEH_heli + T_VEH_plane;

// Ground vehicles
T_VEH_ground			= [T_VEH_default, T_VEH_car_unarmed, T_VEH_car_armed, T_VEH_MRAP_unarmed, T_VEH_MRAP_HMG, T_VEH_MRAP_GMG, T_VEH_IFV, T_VEH_APC, T_VEH_MBT, T_VEH_MRLS, T_VEH_SPA, T_VEH_SPAA, T_VEH_truck_inf, T_VEH_truck_cargo, T_VEH_truck_ammo, T_VEH_truck_repair, T_VEH_truck_medical, T_VEH_truck_fuel];

// Static vehicles
T_VEH_static 			= [T_VEH_stat_HMG_high, T_VEH_stat_GMG_high, T_VEH_stat_HMG_low, T_VEH_stat_GMG_low, T_VEH_stat_AA, T_VEH_stat_AT, T_VEH_stat_mortar_light, T_VEH_stat_mortar_heavy]; //Static weapons

// Vehicles requiring specific crew
T_VEH_need_basic_crew 	= [T_VEH_MRAP_HMG, T_VEH_MRAP_GMG, T_VEH_boat_armed]; //Vehicles that need a driver and a gunner, like MRAPs or boats
T_VEH_need_crew 		= [T_VEH_IFV, T_VEH_APC, T_VEH_MBT, T_VEH_MRLS, T_VEH_SPA, T_VEH_SPAA]; //Vehicles that need crew like T_INF_crew
T_VEH_need_heli_crew 	= [T_VEH_heli_light, T_VEH_heli_heavy, T_VEH_heli_cargo, T_VEH_heli_attack]; //Vehicles that need crew like T_INF_pilot_heli and T_INF_crew_heli
T_VEH_need_plane_crew 	= [T_VEH_plane_attack, T_VEH_plane_fighter, T_VEH_plane_cargo]; //Vehicles that need crew like T_INF_pilot

// Vehicles which should be occupied when in combat
T_VEH_combat 			= T_VEH_need_basic_crew + T_VEH_need_crew + T_VEH_need_heli_crew + T_VEH_need_plane_crew + T_VEH_static;

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

// Ground vehicles considered armored
T_VEH_armor =
[
	T_VEH_IFV,
	T_VEH_APC,
	T_VEH_MBT
];

// = = = = = = = = = = D R O N E S = = = = = = = = = = 

//Drones
T_DECLARE_ENTRY_OPT(T_DRONE, T_DRONE_default,			 0); //A vacuum cleaner robot
T_DECLARE_ENTRY_OPT(T_DRONE, T_DRONE_UGV_unarmed,		 1);
T_DECLARE_ENTRY_OPT(T_DRONE, T_DRONE_UGV_armed,			 2);
T_DECLARE_ENTRY_OPT(T_DRONE, T_DRONE_plane_attack,		 3); //Attack drone plane, mainly for air-to-ground
T_DECLARE_ENTRY_OPT(T_DRONE, T_DRONE_plane_unarmed,		 4); //Unarmed drone plane
T_DECLARE_ENTRY_OPT(T_DRONE, T_DRONE_heli_attack,		 5); //Attack helicopter
T_DECLARE_ENTRY_OPT(T_DRONE, T_DRONE_quadcopter,		 6);
T_DECLARE_ENTRY_OPT(T_DRONE, T_DRONE_designator,		 7); //Remote designator
T_DECLARE_ENTRY_OPT(T_DRONE, T_DRONE_stat_HMG_low,		 8);
T_DECLARE_ENTRY_OPT(T_DRONE, T_DRONE_stat_GMG_low,		 9);
T_DECLARE_ENTRY_OPT(T_DRONE, T_DRONE_stat_AA,			10);

// = = = = = = = = = = C A R G O = = = = = = = = = = 

T_DECLARE_ENTRY_REQ(T_CARGO, T_CARGO_default,			 0)		[T_FACTION_Guer, T_FACTION_Military, T_FACTION_Police];
T_DECLARE_ENTRY_REQ(T_CARGO, T_CARGO_box_small,			 1)		[T_FACTION_Guer, T_FACTION_Military, T_FACTION_Police];
T_DECLARE_ENTRY_REQ(T_CARGO, T_CARGO_box_medium,		 2)		[T_FACTION_Guer, T_FACTION_Military, T_FACTION_Police];
T_DECLARE_ENTRY_REQ(T_CARGO, T_CARGO_box_big,			 3)		[T_FACTION_Guer, T_FACTION_Military, T_FACTION_Police];

// = = = = = = = = = = G R O U P S = = = = = = = = = = 

T_DECLARE_ENTRY_REQ(T_GROUP, T_GROUP_default,			 0)		[T_FACTION_Guer, T_FACTION_Military, T_FACTION_Police]; //Default group if group is not specified
T_DECLARE_ENTRY_OPT(T_GROUP, T_GROUP_inf_AA_team,		 1);
T_DECLARE_ENTRY_OPT(T_GROUP, T_GROUP_inf_AT_team,		 2);
T_DECLARE_ENTRY_OPT(T_GROUP, T_GROUP_inf_rifle_squad,	 3);
T_DECLARE_ENTRY_OPT(T_GROUP, T_GROUP_inf_assault_squad,	 4);
T_DECLARE_ENTRY_OPT(T_GROUP, T_GROUP_inf_weapons_squad,	 5);
T_DECLARE_ENTRY_OPT(T_GROUP, T_GROUP_inf_fire_team,		 6);
T_DECLARE_ENTRY_OPT(T_GROUP, T_GROUP_inf_recon_patrol,	 7);
T_DECLARE_ENTRY_OPT(T_GROUP, T_GROUP_inf_recon_sentry,	 8);
T_DECLARE_ENTRY_OPT(T_GROUP, T_GROUP_inf_recon_squad,	 9);
T_DECLARE_ENTRY_OPT(T_GROUP, T_GROUP_inf_recon_team,	10);
T_DECLARE_ENTRY_OPT(T_GROUP, T_GROUP_inf_sentry,		11);
T_DECLARE_ENTRY_OPT(T_GROUP, T_GROUP_inf_sniper_team,	12);
T_DECLARE_ENTRY_OPT(T_GROUP, T_GROUP_inf_officer,		13);

// = = = = = = = = = = P L A C E M E N T = = = = = = = = = = 

//Subcategories sorted by their Placement type
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

T_PL_helicopters = //All helicopters including drones
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

// Main infantry -- excluding officers, recon, and divers
// 
T_PL_inf_main =
[
	[T_INF, T_INF_SL],
	[T_INF, T_INF_TL],
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

// Special infantry -- officers, recon, and divers
// These will not be sent places without explicit orders
T_PL_inf_special = 
[
	[T_INF, T_INF_officer],

	[T_INF, T_INF_recon_TL],
	[T_INF, T_INF_recon_rifleman],
	[T_INF, T_INF_recon_medic],
	[T_INF, T_INF_recon_exp],
	[T_INF, T_INF_recon_LAT],
	[T_INF, T_INF_recon_marksman],
	[T_INF, T_INF_recon_JTAC],

	[T_INF, T_INF_diver_TL],
	[T_INF, T_INF_diver_rifleman],
	[T_INF, T_INF_diver_exp]
];

// Cargo boxes
T_PL_cargo =
[
	[T_CARGO, T_CARGO_box_small],
	[T_CARGO, T_CARGO_box_medium],
	[T_CARGO, T_CARGO_box_big]
];

T_PL_cargo_small_medium =
[
	[T_CARGO, T_CARGO_box_small],
	[T_CARGO, T_CARGO_box_medium]
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

// = = = = = = = = = = I N V E N T O R Y = = = = = = = = = = 

// Subcategories
T_INV_primary			= 0;	// Array of [_weapon, _magazines]
T_INV_primary_items		= 1;
T_INV_secondary			= 2;	// Array of [_weapon, _magazines]
T_INV_secondary_items	= 3;
T_INV_handgun			= 4;	// Array of [_weapon, _magazines]
T_INV_handgun_items		= 5;
T_INV_items				= 6;	// Array of item class names
T_INV_headgear			= 7;
T_INV_vests				= 8;
T_INV_backpacks			= 9;
T_INV_NVGs				= 10;	// Night vision goggles
T_INV_grenades			= 11;	// All kinds of grenades
T_INV_explosives		= 12;	// Explosives
T_INV_primary_sorted	= 13;	// Arrays of arrays of form [_weapon, _magazines, _items],
T_INV_secondary_sorted  = 14;	// For each infantry subcategory
T_INV_NVG_scale			= 15;	// Number 0..1, scale of NVG amount, calculated from ratio of NVG to non-NVG soldiers
T_INV_size				= 16;
// Cargo space of vehicles (ACE cargo)

#define T_DECLARE_CARGO_SPACE(catId, space) T_cargoSpace set [catId, space];

T_cargoSpace = [];
T_cargoSpace resize T_VEH_SIZE;

T_DECLARE_CARGO_SPACE(T_VEH_default,                 4);
T_DECLARE_CARGO_SPACE(T_VEH_car_unarmed,			 8);
T_DECLARE_CARGO_SPACE(T_VEH_car_armed,				 8);
T_DECLARE_CARGO_SPACE(T_VEH_MRAP_unarmed,			 8);
T_DECLARE_CARGO_SPACE(T_VEH_MRAP_HMG,				 8);
T_DECLARE_CARGO_SPACE(T_VEH_MRAP_GMG,				 8);
T_DECLARE_CARGO_SPACE(T_VEH_IFV,					 8);
T_DECLARE_CARGO_SPACE(T_VEH_APC,					 8);
T_DECLARE_CARGO_SPACE(T_VEH_MBT,					 8);
T_DECLARE_CARGO_SPACE(T_VEH_MRLS,					 8);	//Multiple Rocket Launch System
T_DECLARE_CARGO_SPACE(T_VEH_SPA,					8);	//Self-Propelled Artillery
T_DECLARE_CARGO_SPACE(T_VEH_SPAA,					8);	//Self-Propelled Anti-Aircraft system
T_DECLARE_CARGO_SPACE(T_VEH_stat_HMG_high,			0);
T_DECLARE_CARGO_SPACE(T_VEH_stat_GMG_high,			0);
T_DECLARE_CARGO_SPACE(T_VEH_stat_HMG_low,			0);
T_DECLARE_CARGO_SPACE(T_VEH_stat_GMG_low,			0);
T_DECLARE_CARGO_SPACE(T_VEH_stat_AA,				0);
T_DECLARE_CARGO_SPACE(T_VEH_stat_AT,				0);
T_DECLARE_CARGO_SPACE(T_VEH_stat_mortar_light,      0);	//Light mortar
T_DECLARE_CARGO_SPACE(T_VEH_stat_mortar_heavy,      0);	//Heavy mortar, because RHS has some
T_DECLARE_CARGO_SPACE(T_VEH_heli_light,             20);	//Light transport helicopter for infantry
T_DECLARE_CARGO_SPACE(T_VEH_heli_heavy,             20);	//Heavy transport helicopter, both for cargo and infantry
T_DECLARE_CARGO_SPACE(T_VEH_heli_cargo,             20);	//Heavy transport helicopter only for cargo
T_DECLARE_CARGO_SPACE(T_VEH_heli_attack, 			20);	//Attack helicopter
T_DECLARE_CARGO_SPACE(T_VEH_plane_attack,			4);	//Attack plane, mainly for air-to-ground
T_DECLARE_CARGO_SPACE(T_VEH_plane_fighter,			4);	//Fighter plane
T_DECLARE_CARGO_SPACE(T_VEH_plane_cargo,			4);	//Cargo plane
T_DECLARE_CARGO_SPACE(T_VEH_plane_unarmed,			4);	//Light unarmed plane like cessna
T_DECLARE_CARGO_SPACE(T_VEH_plane_VTOL,             20);	//VTOL
T_DECLARE_CARGO_SPACE(T_VEH_boat_unarmed,			10);	//Unarmed boat
T_DECLARE_CARGO_SPACE(T_VEH_boat_armed,             10);	//Armed boat
T_DECLARE_CARGO_SPACE(T_VEH_personal,				3);	//Quad bike or something for 1-2 men personal transport
T_DECLARE_CARGO_SPACE(T_VEH_truck_inf,				20);	//Truck for infantry transport
T_DECLARE_CARGO_SPACE(T_VEH_truck_cargo,			20);	//Truck for general cargo transport
T_DECLARE_CARGO_SPACE(T_VEH_truck_ammo,             20);	//Ammo truck
T_DECLARE_CARGO_SPACE(T_VEH_truck_repair,           20);	//Repair truck
T_DECLARE_CARGO_SPACE(T_VEH_truck_medical,			20);	//Medical truck
T_DECLARE_CARGO_SPACE(T_VEH_truck_fuel,             20);	//Fuel truck
T_DECLARE_CARGO_SPACE(T_VEH_submarine,				6);	//Submarine
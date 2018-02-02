/*
These arrays represent the efficiency  of all units in the templates.

efficiency categories:
|	.	|	.	|	.	|	.	|	.	|	.	|	.	|
[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
*/

T_EFF_soft =	0;
T_EFF_medium =	1;
T_EFF_armor =	2;
T_EFF_air =		3;
T_EFF_aSoft =	4;
T_EFF_aMedium =	5;
T_EFF_aArmor =	6;
T_EFF_aAir =	7;

T_EFF_null = 	[0, 0, 0, 0, 0, 0, 0, 0]; //Empty vector with efficiency


private _eff = [];

//==== INFANTRY ====
private _eff_inf = [];
//									[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
_eff_inf set [T_INF_default,		[1,		0,		0,		0,		1,		0,		0,		0]];
_eff_inf set [T_INF_SL,				[1,		0,		0,		0,		1,		0,		0,		0]];
_eff_inf set [T_INF_TL,				[1,		0,		0,		0,		1,		0,		0,		0]];
_eff_inf set [T_INF_officer,		[1,		0,		0,		0,		1,		0,		0,		0]];
//									[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
_eff_inf set [T_INF_GL,				[1,		0,		0,		0,		2,		0,		0,		0]];
_eff_inf set [T_INF_rifleman,		[1,		0,		0,		0,		1,		0,		0,		0]];
_eff_inf set [T_INF_marksman,		[1,		0,		0,		0,		1,		0,		0,		0]];
_eff_inf set [T_INF_sniper,			[1,		0,		0,		0,		1,		0,		0,		0]];
//									[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
_eff_inf set [T_INF_spotter,		[1,		0,		0,		0,		1,		0,		0,		0]];
_eff_inf set [T_INF_exp,			[1,		0,		0,		0,		1,		0,		0,		0]];
_eff_inf set [T_INF_ammo,			[1,		0,		0,		0,		1,		0,		0,		0]];
_eff_inf set [T_INF_LAT,			[1,		0,		0,		0,		1,		1,		1,		0]];
//									[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
_eff_inf set [T_INF_AT,				[1,		0,		0,		0,		1,		2,		2,		0]];
_eff_inf set [T_INF_AA,				[1,		0,		0,		0,		1,		0,		0,		1]];
_eff_inf set [T_INF_LMG,			[1,		0,		0,		0,		2,		0,		0,		0]];
_eff_inf set [T_INF_HMG,			[1,		0,		0,		0,		2,		0,		0,		0]];
//									[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
_eff_inf set [T_INF_medic,			[1,		0,		0,		0,		1,		0,		0,		0]];
_eff_inf set [T_INF_engineer,		[1,		0,		0,		0,		1,		0,		0,		0]];
_eff_inf set [T_INF_crew,			[1,		0,		0,		0,		0,		0,		0,		0]];
_eff_inf set [T_INF_crew_heli,		[1,		0,		0,		0,		0,		0,		0,		0]];
//									[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
_eff_inf set [T_INF_pilot,			[1,		0,		0,		0,		0,		0,		0,		0]];
_eff_inf set [T_INF_pilot_heli,		[1,		0,		0,		0,		0,		0,		0,		0]];
_eff_inf set [T_INF_survivor,		[1,		0,		0,		0,		0,		0,		0,		0]];
_eff_inf set [T_INF_unarmed,		[1,		0,		0,		0,		0,		0,		0,		0]];
//									[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
_eff_inf set [T_INF_recon_TL,		[1,		0,		0,		0,		1,		0,		0,		0]];
_eff_inf set [T_INF_recon_rifleman,	[1,		0,		0,		0,		1,		0,		0,		0]];
_eff_inf set [T_INF_recon_medic,	[1,		0,		0,		0,		1,		0,		0,		0]];
_eff_inf set [T_INF_recon_exp,		[1,		0,		0,		0,		1,		0,		0,		0]];
//									[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
_eff_inf set [T_INF_recon_LAT,		[1,		0,		0,		0,		1,		1,		1,		0]];
_eff_inf set [T_INF_recon_marksman,	[1,		0,		0,		0,		1,		0,		0,		0]];
_eff_inf set [T_INF_recon_JTAC,		[1,		0,		0,		0,		1,		0,		0,		0]];
_eff_inf set [T_INF_diver_TL,		[1,		0,		0,		0,		1,		0,		0,		0]];
//									[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
_eff_inf set [T_INF_diver_rifleman,	[1,		0,		0,		0,		1,		0,		0,		0]];
_eff_inf set [T_INF_diver_exp,		[1,		0,		0,		0,		1,		0,		0,		0]];
//									[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
_eff set [T_INF, _eff_inf];

//==== VEHICLES ====
private _eff_veh = [];
//											[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
_eff_veh set [T_VEH_default,				[0,		0,		0,		0,		0,		0,		0,		0]];
_eff_veh set [T_VEH_car_unarmed,			[2,		0,		0,		0,		0,		0,		0,		0]];
_eff_veh set [T_VEH_car_armed,				[3,		0,		0,		0,		3,		0,		0,		0]];
_eff_veh set [T_VEH_MRAP_unarmed,			[0,		1,		0,		0,		0,		0,		0,		0]];
//											[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
_eff_veh set [T_VEH_MRAP_HMG,				[0,		1,		0,		0,		5,		2,		0,		0]];
_eff_veh set [T_VEH_MRAP_GMG,				[0,		1,		0,		0,		5,		2,		0,		0]];
_eff_veh set [T_VEH_IFV,					[0,		0,		1,		0,		10,		4,		1,		0]];
_eff_veh set [T_VEH_APC,					[0,		0,		1,		0,		8,		3,		1,		0]];
//											[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
_eff_veh set [T_VEH_MBT,					[0,		0,		2,		0,		10,		10,		2,		0]];
_eff_veh set [T_VEH_MRLS,					[0,		0,		1,		0,		0,		0,		0,		0]];
_eff_veh set [T_VEH_SPA,					[0,		0,		1,		0,		0,		0,		0,		0]];
_eff_veh set [T_VEH_SPAA,					[0,		0,		1,		0,		0,		0,		0,		6]];
//											[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
_eff_veh set [T_VEH_stat_HMG_high,			[3,		0,		0,		0,		3,		2,		0,		0]];
_eff_veh set [T_VEH_stat_GMG_high,			[3,		0,		0,		0,		3,		2,		0,		0]];
_eff_veh set [T_VEH_stat_HMG_low,			[3,		0,		0,		0,		3,		2,		0,		0]];
_eff_veh set [T_VEH_stat_GMG_low,			[3,		0,		0,		0,		3,		2,		0,		0]];
//											[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
_eff_veh set [T_VEH_stat_AA,				[3,		0,		0,		0,		0,		0,		0,		3]];
_eff_veh set [T_VEH_stat_AT,				[3,		0,		0,		0,		0,		2,		2,		0]];
_eff_veh set [T_VEH_stat_mortar_light,		[3,		0,		0,		0,		8,		0,		0,		0]];
_eff_veh set [T_VEH_stat_mortar_heavy,		[3,		0,		0,		0,		10,		0,		0,		0]];
//											[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
_eff_veh set [T_VEH_heli_light,				[0,		0,		0,		1,		0,		0,		0,		0]];
_eff_veh set [T_VEH_heli_heavy,				[0,		0,		0,		1,		0,		0,		0,		0]];
_eff_veh set [T_VEH_heli_cargo,				[0,		0,		0,		1,		0,		0,		0,		0]];
_eff_veh set [T_VEH_heli_attack,			[0,		0,		0,		2,		0,		10,		10,		0]];
//											[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
_eff_veh set [T_VEH_plane_attack,			[0,		0,		0,		3,		0,		15,		15,		4]];
_eff_veh set [T_VEH_plane_fighter,			[0,		0,		0,		3,		0,		0,		0,		6]];
_eff_veh set [T_VEH_plane_cargo,			[0,		0,		0,		1,		0,		0,		0,		0]];
_eff_veh set [T_VEH_plane_unarmed,			[0,		0,		0,		1,		0,		0,		0,		0]];
//											[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
_eff_veh set [T_VEH_plane_VTOL,				[0,		0,		0,		2,		0,		0,		0,		0]];
_eff_veh set [T_VEH_boat_unarmed,			[3,		0,		0,		0,		0,		0,		0,		0]];
_eff_veh set [T_VEH_boat_armed,				[0,		1,		0,		0,		3,		1,		0,		0]];
_eff_veh set [T_VEH_personal,				[1,		0,		0,		0,		0,		0,		0,		0]];
//											[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
_eff_veh set [T_VEH_truck_inf,				[3,		0,		0,		0,		0,		0,		0,		0]];
_eff_veh set [T_VEH_truck_cargo,			[3,		0,		0,		0,		0,		0,		0,		0]];
_eff_veh set [T_VEH_truck_ammo,				[3,		0,		0,		0,		0,		0,		0,		0]];
_eff_veh set [T_VEH_truck_repair,			[3,		0,		0,		0,		0,		0,		0,		0]];
//											[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
_eff_veh set [T_VEH_truck_medical,			[3,		0,		0,		0,		0,		0,		0,		0]];
_eff_veh set [T_VEH_truck_fuel,				[3,		0,		0,		0,		0,		0,		0,		0]];
_eff_veh set [T_VEH_submarine,				[1,		0,		0,		0,		0,		0,		0,		0]];
//											[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
_eff set [T_VEH, _eff_veh];

//==== DRONES ====
private _eff_drone = [];
//										[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
_eff_drone set [T_DRONE_default, 		[0,		0,		0,		0,		0,		0,		0,		0]];
_eff_drone set [T_DRONE_UGV_unarmed,	[4,		0,		0,		0,		0,		0,		0,		0]];
_eff_drone set [T_DRONE_UGV_armed,		[4,		0,		0,		0,		5,		2,		0,		0]];
_eff_drone set [T_DRONE_plane_attack,	[0,		0,		0,		3,		0,		8,		8,		0]];
//										[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
_eff_drone set [T_DRONE_plane_unarmed,	[0,		0,		0,		1,		0,		0,		0,		0]];
_eff_drone set [T_DRONE_heli_attack,	[0,		0,		0,		3,		0,		8,		8,		0]];
_eff_drone set [T_DRONE_quadcopter,		[1,		0,		0,		0,		0,		0,		0,		0]];
_eff_drone set [T_DRONE_designator,		[1,		0,		0,		0,		0,		0,		0,		0]];
//										[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
_eff_drone set [T_DRONE_stat_HMG_low,	[2,		0,		0,		0,		4,		2,		0,		0]];
_eff_drone set [T_DRONE_stat_GMG_low,	[2,		0,		0,		0,		4,		2,		0,		0]];
_eff_drone set [T_DRONE_stat_AA,		[2,		0,		0,		0,		0,		0,		0,		4]];
//										[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
_eff set [T_DRONE, _eff_drone];

T_efficiency = +_eff;
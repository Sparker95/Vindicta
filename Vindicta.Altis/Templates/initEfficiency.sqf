#include "Efficiency.hpp"
/*
These arrays represent the efficiency of all units in the templates.

efficiency categories (a- is anti-):
|	.	|	.	|	.	|	.	|	.	|	.	|	.	|
[soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air]
*/

T_EFF_soft			= 0;	// Amount of 'soft' armor	which can be defeated with any weapons
T_EFF_medium		= 1;	// Amount of 'medium' armor	which can be defeated with >=12mm weapons
T_EFF_armor			= 2;	// Amount of 'hard' armor	which can be defeated with >=20mm or AT weapons
T_EFF_air			= 3;	// >0 for air units
T_EFF_aSoft			= 4;	// Efifciency against soft		targets
T_EFF_aMedium		= 5;	// Efifciency against medium	targets
T_EFF_aArmor		= 6;	// Efifciency against armor		targets
T_EFF_aAir			= 7;	// Efifciency against air		targets
T_EFF_reqTransport	= 8;	// Amount of transport space required (1 for infantry)
T_EFF_transport		= 9;	// Amount of transport space provided
T_EFF_ground		= 10;	// >0 for ground units
T_EFF_water			= 11;	// >0 for water units
T_EFF_reqCrew		= 12;	// Amount of crew required to operate this
T_EFF_crew			= 13;	// >0 if this unit can serve as crew (around 1 for infantry)

T_EFF_constraintsPayload = [T_EFF_aSoft, T_EFF_aMedium, T_EFF_aArmor, T_EFF_aAir];	// Array of payload constraint types (combat constraints)
T_EFF_constraintsTransport = [T_EFF_transport, T_EFF_crew];							// Array of transport constraint types

private _eff = [];

//==== PRESETS ====
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
// Empty vector with efficiency				|		|		|		|		|		|		|		|		|		|		|		|		|		|
T_EFF_null = 								[0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0];
T_EFF_ones =								[1,		1,		1,		1,		1,		1,		1,		1,		1,		1,		1,		1,		1,		1];
T_EFF_att_mask = 							[0,		0,		0,		0,		1,		1,		1,		1,		0,		0,		0,		0,		0,		0];
T_EFF_def_mask =							[1,		1,		1,		1,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0];
T_EFF_def_att_mask = 						[1,		1,		1,		1,		1,		1,		1,		1,		0,		0,		0,		0,		0,		0];
T_EFF_ground_mask =							[0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		1,		0,		0,		0];
T_EFF_air_mask =							[0,		0,		0,		1,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0];
T_EFF_water_mask =							[0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		1,		0,		0];
T_EFF_transport_mask =						[0,		0,		0,		0,		0,		0,		0,		0,		0,		1,		0,		0,		0,		0];
T_EFF_infantry_mask =						[0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		1];
// Default value if there is no efficiency value on a unit
T_EFF_default = 							[1,		0,		0,		0,		1,		0,		0,		0,		0,		0,		1,		0,		0,		1];

//==== INFANTRY ====
private _eff_inf = [];
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
_eff_inf set [T_INF_default,				[1,		0,		0,		0,		1,		0,		0,		0,		1,		0,		1,		0,		0,		1]];
_eff_inf set [T_INF_SL,						[1,		0,		0,		0,		0.7,	0,		0,		0,		1,		0,		1,		0,		0,		1]];
_eff_inf set [T_INF_TL,						[1,		0,		0,		0,		0.5,	0,		0,		0,		1,		0,		1,		0,		0,		1]];
_eff_inf set [T_INF_officer,				[1,		0,		0,		0,		0,		0,		0,		0,		1,		0,		1,		0,		0,		1]];
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
_eff_inf set [T_INF_GL,						[1,		0,		0,		0,		1.3,	0,		0,		0,		1,		0,		1,		0,		0,		1]];
_eff_inf set [T_INF_rifleman,				[1,		0,		0,		0,		1,		0,		0,		0,		1,		0,		1,		0,		0,		1]];
_eff_inf set [T_INF_marksman,				[1,		0,		0,		0,		1.4,	0,		0,		0,		1,		0,		1,		0,		0,		1]];
_eff_inf set [T_INF_sniper,					[1,		0,		0,		0,		1.4,	0,		0,		0,		1,		0,		1,		0,		0,		1]];
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
_eff_inf set [T_INF_spotter,				[1,		0,		0,		0,		1,		0,		0,		0,		1,		0,		1,		0,		0,		1]];
_eff_inf set [T_INF_exp,					[1,		0,		0,		0,		1,		0,		0,		0,		1,		0,		1,		0,		0,		1]];
_eff_inf set [T_INF_ammo,					[1,		0,		0,		0,		1,		0,		0,		0,		1,		0,		1,		0,		0,		1]];
_eff_inf set [T_INF_LAT,					[1,		0,		0,		0,		0.8,	0.9,	0.4,	0,		1,		0,		1,		0,		0,		1]];
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
_eff_inf set [T_INF_AT,						[1,		0,		0,		0,		0.7,	1.9,	0.6,	0,		1,		0,		1,		0,		0,		1]];
_eff_inf set [T_INF_AA,						[1,		0,		0,		0,		0.7,	0,		0,		1,		1,		0,		1,		0,		0,		1]];
_eff_inf set [T_INF_LMG,					[1,		0,		0,		0,		1.5,	0,		0,		0,		1,		0,		1,		0,		0,		1]];
_eff_inf set [T_INF_HMG,					[1,		0,		0,		0,		1.6,	0,		0,		0,		1,		0,		1,		0,		0,		1]];
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
_eff_inf set [T_INF_medic,					[1,		0,		0,		0,		0.7,	0,		0,		0,		1,		0,		1,		0,		0,		1]];
_eff_inf set [T_INF_engineer,				[1,		0,		0,		0,		1,		0,		0,		0,		1,		0,		1,		0,		0,		1]];
_eff_inf set [T_INF_crew,					[1,		0,		0,		0,		0,		0,		0,		0,		1,		0,		1,		0,		0,		1]];
_eff_inf set [T_INF_crew_heli,				[1,		0,		0,		0,		0,		0,		0,		0,		1,		0,		1,		0,		0,		1]];
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
_eff_inf set [T_INF_pilot,					[1,		0,		0,		0,		0,		0,		0,		0,		1,		0,		1,		0,		0,		1]];
_eff_inf set [T_INF_pilot_heli,				[1,		0,		0,		0,		0,		0,		0,		0,		1,		0,		1,		0,		0,		1]];
_eff_inf set [T_INF_survivor,				[1,		0,		0,		0,		0,		0,		0,		0,		1,		0,		1,		0,		0,		0]];
_eff_inf set [T_INF_unarmed,				[1,		0,		0,		0,		0,		0,		0,		0,		1,		0,		1,		0,		0,		0]];
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
_eff_inf set [T_INF_recon_TL,				[1,		0,		0,		0,		0,		0,		0,		0,		1,		0,		1,		0,		0,		1]];
_eff_inf set [T_INF_recon_rifleman,			[1,		0,		0,		0,		0,		0,		0,		0,		1,		0,		1,		0,		0,		1]];
_eff_inf set [T_INF_recon_medic,			[1,		0,		0,		0,		0,		0,		0,		0,		1,		0,		1,		0,		0,		1]];
_eff_inf set [T_INF_recon_exp,				[1,		0,		0,		0,		0,		0,		0,		0,		1,		0,		1,		0,		0,		1]];
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
_eff_inf set [T_INF_recon_LAT,				[1,		0,		0,		0,		0,		0,		0,		0,		1,		0,		1,		0,		0,		1]];
_eff_inf set [T_INF_recon_marksman,			[1,		0,		0,		0,		0,		0,		0,		0,		1,		0,		1,		0,		0,		1]];
_eff_inf set [T_INF_recon_JTAC,				[1,		0,		0,		0,		0,		0,		0,		0,		1,		0,		1,		0,		0,		1]];
_eff_inf set [T_INF_diver_TL,				[1,		0,		0,		0,		0,		0,		0,		0,		1,		0,		1,		0,		0,		1]];
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
_eff_inf set [T_INF_diver_rifleman,			[0.8,	0,		0,		0,		0,		0,		0,		0,		1,		0,		1,		0,		0,		0]];	// Divers are very special
_eff_inf set [T_INF_diver_exp,				[0.8,	0,		0,		0,		0,		0,		0,		0,		1,		0,		1,		0,		0,		0]];
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
_eff set [T_INF, _eff_inf];

//==== VEHICLES ====
private _eff_veh = [];
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
_eff_veh set [T_VEH_default,				[0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		1,		0,		0,		0]];
_eff_veh set [T_VEH_car_unarmed,			[2,		0,		0,		0,		0,		0,		0,		0,		0,		2,		1,		0,		1,		0]];
_eff_veh set [T_VEH_car_armed,				[3,		0,		0,		0,		3,		0,		0,		0,		0,		2,		1,		0,		2,		0]];
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
_eff_veh set [T_VEH_MRAP_unarmed,			[0,		1,		0,		0,		0,		0,		0,		0,		0,		2,		1,		0,		1,		0]];
_eff_veh set [T_VEH_MRAP_HMG,				[0,		1,		0,		0,		5,		2,		0,		0,		0,		2,		1,		0,		2,		0]];
_eff_veh set [T_VEH_MRAP_GMG,				[0,		1,		0,		0,		5,		2,		0,		0,		0,		2,		1,		0,		2,		0]];
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
_eff_veh set [T_VEH_IFV,					[0,		0,		1,		0,		10,		4,		0.7,	0,		0,		7,		1,		0,		3,		0]];
_eff_veh set [T_VEH_APC,					[0,		0,		1,		0,		8,		3,		0.5,	0,		0,		7,		1,		0,		3,		0]];
_eff_veh set [T_VEH_MBT,					[0,		0,		2,		0,		10,		10,		3,		0,		0,		0,		1,		0,		3,		0]];
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
_eff_veh set [T_VEH_MRLS,					[0,		0,		1,		0,		0,		0,		0,		0,		0,		0,		1,		0,		2,		0]];
_eff_veh set [T_VEH_SPA,					[0,		0,		1,		0,		0,		0,		0,		0,		0,		0,		1,		0,		2,		0]];
_eff_veh set [T_VEH_SPAA,					[0,		0,		1,		0,		0,		0,		0,		6,		0,		0,		1,		0,		2,		0]];
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
_eff_veh set [T_VEH_stat_HMG_high,			[3,		0,		0,		0,		3,		2,		0,		0,		0.2,	0,		1,		0,		1,		0]];
_eff_veh set [T_VEH_stat_GMG_high,			[3,		0,		0,		0,		3,		2,		0,		0,		0.2,	0,		1,		0,		1,		0]];
_eff_veh set [T_VEH_stat_HMG_low,			[3,		0,		0,		0,		3,		2,		0,		0,		0.2,	0,		1,		0,		1,		0]];
_eff_veh set [T_VEH_stat_GMG_low,			[3,		0,		0,		0,		3,		2,		0,		0,		0.2,	0,		1,		0,		1,		0]];
_eff_veh set [T_VEH_stat_AA,				[3,		0,		0,		0,		0,		0,		0,		3,		0.2,	0,		1,		0,		1,		0]];
_eff_veh set [T_VEH_stat_AT,				[3,		0,		0,		0,		0,		2,		2,		0,		0.2,	0,		1,		0,		1,		0]];
_eff_veh set [T_VEH_stat_mortar_light,		[3,		0,		0,		0,		8,		0,		0,		0,		0.2,	0,		1,		0,		1,		0]];
_eff_veh set [T_VEH_stat_mortar_heavy,		[3,		0,		0,		0,		10,		0,		0,		0,		0.2,	0,		1,		0,		1,		0]];
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
_eff_veh set [T_VEH_heli_light,				[0,		0,		0,		1,		0,		0,		0,		0,		0,		3,		0,		0,		1,		0]];
_eff_veh set [T_VEH_heli_heavy,				[0,		0,		0,		1,		0,		0,		0,		0,		0,		12,		0,		0,		2,		0]];
_eff_veh set [T_VEH_heli_cargo,				[0,		0,		0,		1,		0,		0,		0,		0,		0,		12,		0,		0,		2,		0]];
_eff_veh set [T_VEH_heli_attack,			[0,		0,		0,		2,		10,		15,		6,		0,		0,		0,		0,		0,		2,		0]];
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
_eff_veh set [T_VEH_plane_attack,			[0,		0,		0,		3,		10,		15,		10,		4,		0,		0,		0,		0,		1,		0]];
_eff_veh set [T_VEH_plane_fighter,			[0,		0,		0,		3,		0,		0,		0,		6,		0,		0,		0,		0,		1,		0]];
_eff_veh set [T_VEH_plane_cargo,			[0,		0,		0,		1,		0,		0,		0,		0,		0,		30,		0,		0,		1,		0]];
_eff_veh set [T_VEH_plane_unarmed,			[0,		0,		0,		1,		0,		0,		0,		0,		0,		1,		0,		0,		1,		0]];
_eff_veh set [T_VEH_plane_VTOL,				[0,		0,		0,		2,		0,		0,		0,		0,		0,		12,		0,		0,		1,		0]];
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
_eff_veh set [T_VEH_truck_inf,				[3,		0,		0,		0,		0,		0,		0,		0,		0,		12,		1,		0,		1,		0]];
_eff_veh set [T_VEH_truck_cargo,			[3,		0,		0,		0,		0,		0,		0,		0,		0,		1,		1,		0,		1,		0]];
_eff_veh set [T_VEH_truck_ammo,				[3,		0,		0,		0,		0,		0,		0,		0,		0,		1,		1,		0,		1,		0]];
_eff_veh set [T_VEH_truck_repair,			[3,		0,		0,		0,		0,		0,		0,		0,		0,		1,		1,		0,		1,		0]];
_eff_veh set [T_VEH_truck_medical,			[3,		0,		0,		0,		0,		0,		0,		0,		0,		1,		1,		0,		1,		0]];
_eff_veh set [T_VEH_truck_fuel,				[3,		0,		0,		0,		0,		0,		0,		0,		0,		1,		1,		0,		1,		0]];
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
_eff_veh set [T_VEH_boat_unarmed,			[3,		0,		0,		0,		0,		0,		0,		0,		0,		4,		0,		1,		1,		0]];
_eff_veh set [T_VEH_boat_armed,				[0,		1,		0,		0,		3,		1,		0,		0,		0,		4,		0,		1,		3,		0]];
_eff_veh set [T_VEH_personal,				[1,		0,		0,		0,		0,		0,		0,		0,		0,		1,		1,		0,		1,		0]];
_eff_veh set [T_VEH_submarine,				[1,		0,		0,		0,		0,		0,		0,		0,		0,		1,		0,		1,		1,		0]];
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
_eff set [T_VEH, _eff_veh];

//==== DRONES ====
private _eff_drone = [];
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
_eff_drone set [T_DRONE_default, 			[0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0]];
_eff_drone set [T_DRONE_UGV_unarmed,		[4,		0,		0,		0,		0,		0,		0,		0,		0,		0,		1,		0,		0,		0]];
_eff_drone set [T_DRONE_UGV_armed,			[4,		0,		0,		0,		5,		2,		0,		0,		0,		0,		1,		0,		0,		0]];
_eff_drone set [T_DRONE_plane_attack,		[0,		0,		0,		3,		0,		8,		8,		0,		0,		0,		0,		0,		0,		0]];
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
_eff_drone set [T_DRONE_plane_unarmed,		[0,		0,		0,		1,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0]];
_eff_drone set [T_DRONE_heli_attack,		[0,		0,		0,		3,		0,		8,		8,		0,		0,		0,		0,		0,		0,		0]];
_eff_drone set [T_DRONE_quadcopter,			[1,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0]];
_eff_drone set [T_DRONE_designator,			[1,		0,		0,		0,		0,		0,		0,		0,		0,		0,		1,		0,		0,		0]];
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
_eff_drone set [T_DRONE_stat_HMG_low,		[2,		0,		0,		0,		4,		2,		0,		0,		0.2,	0,		1,		0,		0,		0]];
_eff_drone set [T_DRONE_stat_GMG_low,		[2,		0,		0,		0,		4,		2,		0,		0,		0.2,	0,		1,		0,		0,		0]];
_eff_drone set [T_DRONE_stat_AA,			[2,		0,		0,		0,		0,		0,		0,		4,		0.2,	0,		1,		0,		0,		0]];
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
_eff set [T_DRONE, _eff_drone];

//==== CARGO ====
private _eff_cargo = [];
//											soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
//											|		|		|		|		|		|		|		|		|		|		|		|		|		|
_eff_cargo set [T_CARGO_default, 			[0,		0,		0,		0,		0,		0,		0,		0,		0.5,	0,		1,		0,		0,		0]];
_eff_cargo set [T_CARGO_box_small, 			[0,		0,		0,		0,		0,		0,		0,		0,		0.5,	0,		1,		0,		0,		0]];
_eff_cargo set [T_CARGO_box_medium, 		[0,		0,		0,		0,		0,		0,		0,		0,		0.5,	0,		1,		0,		0,		0]];
_eff_cargo set [T_CARGO_box_big, 			[0,		0,		0,		0,		0,		0,		0,		0,		0.5,	0,		1,		0,		0,		0]];
_eff set [T_CARGO, _eff_cargo];


// Do post processing to make the numbers float-safe
// We need to do that to avoid floating point round-off errors when we add or substract the numbers a lot of times
// So we round these numbers to nearest (1/2)^n, n=5 in this case, should be enough

for "_cat" from 0 to ((count _eff)-1) do
{
	private _catArray = _eff select _cat;
	for "_i" from 0 to ((count _catArray) - 1 ) do {
		private _vector = _catArray select _i;
		_catArray set [_i, _vector apply {(round (_x*32))/32}];
	};
};

T_efficiency = +_eff;


// Efficiency table sorted by column values
T_efficiencySorted = [];
T_efficiencySortedInv = []; // Sorted by inverse of value (1/value)
private _nCols = count T_EFF_null;

for "_nCol" from 0 to (_nCols - 1) do {
	private _a = [];
	private _b = [];
	for "_catID" from 0 to ((count T_efficiency) - 1) do {
		private _subcat = T_efficiency#_catID;
		for "_subcatID" from 0 to ((count _subcat) - 1) do {
			private _value = _subcat#_subcatID#_nCol;
			if (_value > 0) then {
				_a pushBack [_value, _catID, _subcatID];
				_b pushBack [1/_value, _catID, _subcatID];
			};
		};
	};
	_a sort false; // Descending
	_b sort false;
	T_efficiencySorted pushBack _a;
	T_efficiencySortedInv pushBack _b;
};
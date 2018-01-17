/*
Initializes default garrisons.
*/

params ["_locations"];

//Global coefficients for various unit types
util_tracked_wheeled = 1.0; //1.0;
util_infantry = 1; //1.0;
util_helicopters = 0.5; //1.0;
util_planes = 0.5; //1.0;
util_turrets = 0.5; //1.0;
util_building_sentries = 0.5; //1.0;

private _loc = objNull;
private _type = 0;
private _gar = objNull;
{
	_loc = _x;
	_type = _loc getVariable ["l_type", 0];
	_gar = [_loc] call loc_fnc_getMainGarrison;

	diag_log format ["processing location: %1, its main garrison: %2", _loc, _gar];
	call
	{
		if(_type == LOC_TYPE_base) exitWith
		{

			//Static weapons
			[_loc, _gar,
			[
				[T_VEH, T_VEH_stat_HMG_high, 1],
				[T_VEH, T_VEH_stat_GMG_high, 1]
			], G_GT_veh_static, util_turrets] call loc_fnc_addUnits;
			
			
			//Tracked and wheeled vehicles
			[_loc, _gar,
			[
				[T_VEH, T_VEH_truck_inf, 2],
				[T_VEH, T_VEH_MBT, 1],
				[T_VEH, T_VEH_APC, 1],
				[T_VEH, T_VEH_IFV, 1],
				[T_VEH, T_VEH_MRAP_HMG, 1],
				[T_VEH, T_VEH_MRAP_GMG, 1]
			],G_GT_veh_non_static, util_tracked_wheeled] call loc_fnc_addUnits;

			
			//Sentries in buildings
			[_loc, _gar,
			[
				[T_INF, T_INF_marksman, 2],
				[T_INF, T_INF_GL, 1],
				[T_INF, T_INF_AT, 1]
			],G_GT_building_sentry, util_building_sentries] call loc_fnc_addUnits;
			
			
			//Infantry
			[_loc, _gar,
			[
				[T_GROUP_inf_rifle_squad, G_GT_idle, 2],
				[T_GROUP_inf_sentry, G_GT_patrol, 1]
			], util_infantry] call loc_fnc_addGroups;


			//Tracked and wheeled vehicles

/*
			[_loc, _gar,
			[
				[T_VEH, T_VEH_IFV, 1]
			],G_GT_veh_non_static, 0.25] call loc_fnc_addUnits;
			*/


		};

		if(_type == LOC_TYPE_outpost) exitWith
		{
			//Static weapons

			[_loc, _gar,
			[
				[T_VEH, T_VEH_stat_HMG_high, 3],
				[T_VEH, T_VEH_stat_GMG_high, 1]
			], G_GT_veh_static, util_turrets] call loc_fnc_addUnits;

			//Tracked and wheeled vehicles

			[_loc, _gar,
			[
				[T_VEH, T_VEH_MRAP_HMG, 2],
				[T_VEH, T_VEH_truck_inf, 1]
				//[T_VEH, T_VEH_APC, 1],
				//[T_VEH, T_VEH_IFV, 1]
			],G_GT_veh_non_static, util_tracked_wheeled] call loc_fnc_addUnits;
			

			//Sentries in buildings
			[_loc, _gar,
			[
				[T_INF, T_INF_LMG, 4],
				[T_INF, T_INF_AT, 1]
			],G_GT_building_sentry, util_building_sentries] call loc_fnc_addUnits;


			//Infantry
			[_loc, _gar,
			[
				[T_GROUP_inf_sentry, G_GT_patrol, 1],
				[T_GROUP_inf_rifle_squad, G_GT_idle, 1]
			], util_infantry] call loc_fnc_addGroups;

		};

	};
} forEach _locations;

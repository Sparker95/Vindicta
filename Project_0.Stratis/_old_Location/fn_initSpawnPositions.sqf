/*
Initializes the spawn positions of specified location.
Searches for objects and vehicles of specific types and uses their positions as spawn positions.
*/

params ["_o", ["_debug", true]];

private _radius = _o getVariable ["l_boundingRadius", 5];
_o setVariable ["l_inf_capacity", 0]; //Reset the infantry capacity first.

private _no = _o nearObjects _radius;

private _object = objNull;
private _type = "";
private _bps = []; //Building positions
private _bp = []; //Building position
private _bc = []; //Building capacity
private _inf_capacity = 0;
private _position = [];
private _bdir = 0; //Building direction
{
	_object = _x;
	if([_o, _object] call loc_fnc_insideBorder) then
	{
		_type = typeOf _object;

		//A truck's position defined the position for tracked and wheeled vehicles
		if(_type == "B_Truck_01_transport_F") then
		{
			[_o, T_PL_tracked_wheeled, (getPosATL _object) + [direction _object], [G_GT_idle, G_GT_veh_non_static], false] call loc_fnc_addSpawnPosition;
			deleteVehicle _object;
		};

		//A mortar's position defines the position for mortars
		if(_type == "B_Mortar_01_F") then
		{
			[_o, [[T_VEH, T_VEH_stat_mortar_light]], (getPosATL _object) + [direction _object], [G_GT_idle, G_GT_veh_static], false] call loc_fnc_addSpawnPosition;
			deleteVehicle _object;
		};

		//A low HMG defines a position for low HMGs and low GMGs
		if(_type == "B_HMG_01_F") then
		{
			[_o, T_PL_HMG_GMG_low, (getPosATL _object) + [direction _object], [G_GT_idle, G_GT_veh_static], false] call loc_fnc_addSpawnPosition;
			deleteVehicle _object;
		};

		//A high HMG defines a position for high HMGs and high GMGs
		if(_type == "B_HMG_01_high_F") then
		{
			[_o, T_PL_HMG_GMG_high, (getPosATL _object) + [direction _object], [G_GT_idle, G_GT_veh_static], false] call loc_fnc_addSpawnPosition;
			deleteVehicle _object;
		};

		//Pre-defined positions for static HMG and GMG in buildings. Check buildings.sqf.
		_bps = loc_bp_HGM_GMG_high select { _type in (_x select 0)};
		if(count _bps > 0) then
		{
			//Add every position from the array to the spawn positions array
			{
				_bp = _x;
				_bdir = direction _object;
				if(count _bp == 2) then //This position is defined by building position ID and direction
				{
					_position = _object buildingPos (_bp select 0);
					[
						_o,
						T_PL_HMG_GMG_high,
						_position + [_bdir + (_bp select 1)],
						[G_GT_idle, G_GT_veh_static],
						true
					] call loc_fnc_addSpawnPosition; //["_o", "_typesArray", "_posAndDir", "_groupType", "_isInBuilding"]
				}
				else //This position is defined by offset in cylindrical coordinates
				{
					_position = (getPosATL _object) vectorAdd [(_bp select 0)*(sin (_bdir + (_bp select 1))), (_bp select 0)*(cos (_bdir + (_bp select 1))), _bp select 2];
					[
						_o,
						T_PL_HMG_GMG_high,
						_position + [_bdir + (_bp select 3)],
						[G_GT_idle, G_GT_veh_static],
						true
					] call loc_fnc_addSpawnPosition;
				};
			} forEach ((_bps select 0) select 1);
		};

		//Pre-defined positions for sentries inside buildings. Check buildings.sqf.
		_bps = loc_bp_sentry select { _type in (_x select 0)};
		if(count _bps > 0) then
		{
			//Add every position from the array to the spawn positions array
			{
				_bp = _x;
				_bdir = direction _object;
				if(count _bp == 2) then //This position is defined by building position ID and direction
				{
					_position = _object buildingPos (_bp select 0);
					[
						_o,
						T_PL_inf_main,
						_position + [_bdir + (_bp select 1)],
						[G_GT_building_sentry],
						true
					] call loc_fnc_addSpawnPosition; //["_o", "_typesArray", "_posAndDir", "_groupType", "_isInBuilding"]
				}
				else //This position is defined by offset in cylindrical coordinates
				{
					_position = (getPosATL _object) vectorAdd [(_bp select 0)*(sin (_bdir + (_bp select 1))), (_bp select 0)*(cos (_bdir + (_bp select 1))), _bp select 2];
					[
						_o,
						T_PL_inf_main,
						_position + [_bdir + (_bp select 3)],
						[G_GT_building_sentry],
						true
					] call loc_fnc_addSpawnPosition;
				};
			} forEach ((_bps select 0) select 1);
		};

		//Infantry capacities of buildings. Check buildings.sqf.
		_bc = loc_b_capacity select { _type in (_x select 0)};
		if(count _bc > 0 && ((getDammage _object) < 0.99999)) then //If the building isn't destroyed yet
		{
			_inf_capacity = _o getVariable ["l_inf_capacity", 0];
			_inf_capacity = _inf_capacity + ((_bc select 0) select 1); //Increase the infantry capacity of this location
			_o setVariable ["l_inf_capacity", _inf_capacity];
		};

		if(_type == "Flag_BI_F") then
		{
			//Probably add support for the flag later
		};

		if(_type == "Sign_Arrow_Large_F") then //Red arrow
		{
			deleteVehicle _object;
		};

		if(_type == "Sign_Arrow_Large_Blue_F") then //Red arrow
		{
			deleteVehicle _object;
		};
	};
}forEach _no;

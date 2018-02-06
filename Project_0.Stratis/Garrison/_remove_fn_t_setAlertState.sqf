/*
Used inside the garrison thread to set the alert state.

_justSpawned - if true, AI behaviour functions can do things like placing units right where they should be at this alert state, like patrols at patrol waypoints.
*/

params ["_lo", "_alertState", "_spawned", "_justSpawned"];

diag_log format ["fn_t_setALertState: %1 %2", _alertState, _spawned];

//If garrison isn't spawned, only set the variable value. If it's spawned, also do other things.

private _hGs = []; //Group handles
private _hG = grpNull; //Group handle
private _groups = _lo getVariable ["g_groups", []];
private _groupType = 0;
//Get all groups
{
	_hG = _x select 1;
	if(count(units _hG) != 0) then
	{
		_hGs pushback _hG;
	};
}forEach _groups;

switch (_alertState) do
{
	//No alert state means no behaviour script assigned
	case G_AS_none:
	{
		//Stop previously started scripts
		[_hGs] call AI_fnc_stopBehaviourScript;
		{
			_groupType = _x select 3;
			_hG = _x select 1;
			(units _hG) commandFollow (leader _hG); //Regroup
			//Delete all waypoints of this group
			while {(count (waypoints _hG)) > 0} do
			{
				deleteWaypoint ((waypoints _hG) select 0);
			};
		}forEach _groups;
	};

	//==== Safe state ====
	case G_AS_safe:
	{
		//Stop previously started scripts
		[_hGs] call AI_fnc_stopBehaviourScript;
		//Assign new scripts to groups
		private _hGs_casual = []; //Groups relaxed at the base
		private _hGs_casual_crew = []; //Groups relaxed near their vehicles
		private _hGs_patrol = [];
		//Find groups of specific types
		{
			_groupType = _x select 3;
			_hG = _x select 1;
			call
			{
				if(_groupType == G_GT_building_sentry) exitWith
				{
					_hG setBehaviour "SAFE";
				};

				if(_groupType == G_GT_idle) exitWith
				{
					_hGs_casual pushback _hG;
					_hG setBehaviour "SAFE";
				};

				if(_groupType == G_GT_veh_non_static) exitWith
				{
					_hGs_casual pushback _hG;
					//[_lo, _x select 0, _spawned, false, false, false] call gar_fnc_t_assignVehicleRoles; //Unassign their roles
					(units _hG) orderGetIn false; //All, dismount!
					_hG setBehaviour "SAFE";
				};

				if(_groupType == G_GT_veh_static) exitWith
				{
					_hGs_casual pushback _hG;
					//[_lo, _x select 0, _spawned, false, true, false] call gar_fnc_t_assignVehicleRoles;
					_hG setBehaviour "SAFE";
				};

				if(_groupType == G_GT_patrol) exitWith
				{
					_hGs_patrol pushback _hG;
					_hG setBehaviour "SAFE";
				};
			};
		}forEach _groups;

		//diag_log format ["==== Casual groups: %1", _hGs_casual];
		//diag_log format ["=== Patrols before: %1", _hGs_patrol];
		private _countPatrol = count _hGs_patrol;
		private _countPatrol = ceil (0.3*_countPatrol); //Roughly 30% of patrol squads will be on patrol duty, rounded up so that there's at least one on patrol.
		while {(count _hGs_patrol) != _countPatrol} do //Move one group to 'casual' array until desired amount of patrol groups is left
		{
			_hGs_casual pushBack (_hGs_patrol select 0);
			_hGs_patrol deleteAt 0;
		};
		//diag_log format ["=== Patrols left: %1", _hGs_patrol];

		//Start behaviour scripts for groups
		private _loc = _lo getVariable ["g_location", objNull];
		private _patrolWaypoints = [_loc] call loc_fnc_getPatrolWaypoints; //Array with positions for patrol waypoints
		//Call AI functions
		[_hGs_casual, [_loc, 200], AI_fnc_behaviour_casual] call AI_fnc_startBehaviourScript;
		[_hGs_patrol, [_patrolWaypoints, _justSpawned], AI_fnc_behaviour_patrol] call AI_fnc_startBehaviourScript; //false in parameters is _justSpawned parameter
	};

	//==== Aware state ====
	case G_AS_aware:
	{
		//Stop previously started scripts
		[_hGs] call AI_fnc_stopBehaviourScript;
		//Assign new scripts to groups
		private _hGs_casual = []; //Groups relaxed at the base
		private _hGs_casual_crew = []; //Groups relaxed near their vehicles
		private _hGs_patrol = [];
		//Find groups of specific types
		{
			_groupType = _x select 3;
			_hG = _x select 1;
			call
			{
				if(_groupType == G_GT_idle) exitWith
				{
					_hGs_casual pushback _hG;
					_hG setBehaviour "SAFE";
				};

				if(_groupType == G_GT_building_sentry) exitWith //For sentries only set their behaviour for now
				{
					_hG setBehaviour "AWARE";
				};

				if(_groupType == G_GT_veh_non_static) exitWith
				{
					_hGs_casual_crew pushback _hG;
					(units _hG) orderGetIn false; //All get out of vehicles!
					//[_lo, _x select 0, _spawned, false, true, false] call gar_fnc_t_assignVehicleRoles; //Assign only non-driver roles so that they don't drive around!
					_hG setBehaviour "SAFE";
				};

				if(_groupType == G_GT_veh_static ) exitWith
				{
					_hGs_casual_crew pushback _hG;
					//[_lo, _x select 0, _spawned, false, true, false] call gar_fnc_t_assignVehicleRoles; //Assign only non-driver roles so that they don't drive around!
					_hG setBehaviour "SAFE";
				};

				if(_groupType == G_GT_patrol) exitWith
				{
					_hGs_patrol pushback _hG;
					_hG setBehaviour "SAFE";
				};
			};
		}forEach _groups;

		//Now all patrol groups are on duty

		//Start behaviour scripts for groups
		private _loc = _lo getVariable ["g_location", objNull];
		private _patrolWaypoints = [_loc] call loc_fnc_getPatrolWaypoints; //Array with positions for patrol waypoints
		//Call AI functions
		[_hGs_casual, [_loc, 200], AI_fnc_behaviour_casual] call AI_fnc_startBehaviourScript;
		[_hGs_casual_crew, [_justSpawned], AI_fnc_behaviour_casual_crew] call AI_fnc_startBehaviourScript;
		[_hGs_patrol, [_patrolWaypoints, _justSpawned], AI_fnc_behaviour_patrol] call AI_fnc_startBehaviourScript; //false in parameters is _justSpawned parameter
	};

	//==== Combat state ====
	case G_AS_combat:
	{
		//Stop previously started scripts
		[_hGs] call AI_fnc_stopBehaviourScript;
		private _loc = _lo getVariable ["g_location", objNull];
		private _locPos = getPos _loc;
		private _radius = 0.6 * ([_loc] call loc_fnc_getBoundingRadius);
		//Find groups of specific types
		{
			_groupType = _x select 3;
			_hG = _x select 1;
			call
			{
				if(_groupType == G_GT_idle || _groupType == G_GT_patrol) exitWith
				{
					//todo these groups should RTB and regroup
					_hG setBehaviour "COMBAT";
					(units _hG) commandFollow (leader _hG); //Regroup
					//Add waypoint to the center of base
					_wp = _hG addWaypoint [_locPos, _radius]; //10];
					_wp setWaypointType "MOVE";
					_wp setWaypointSpeed "FULL"; //"LIMITED";
					_wp setWaypointFormation "WEDGE";
				};

				if(_groupType == G_GT_veh_static || _groupType == G_GT_veh_non_static) exitWith
				{
					//[_lo, _x select 0, _spawned, true, true, false] call gar_fnc_t_assignVehicleRoles; //Assign only non-driver roles so that they don't drive around!
					(units _hG) orderGetIn true; //All, board that vehicle!
					_hG setBehaviour "COMBAT";
				};

				if(_groupType == G_GT_building_sentry) exitWith //For sentries only set their behaviour for now
				{
					_hG setBehaviour "COMBAT";
				};
			};
		}forEach _groups;

		//Start behaviour scripts for groups
	};
};

_lo setVariable ["g_alertState", _alertState];
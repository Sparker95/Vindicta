/*
Search and destroy task.

Task parameters:
	["_target", "_searchRadius", "_timeout"];
*/

#define DEBUG

#define SLEEP_TIME 2
#define SLEEP_RESOLUTION 0.1

params ["_to"]; //Task object

private _hScript = _to spawn
{
	params ["_to"];
	
	//Initialize variables
	private _gar = _to getVariable "AI_garrison";	
	private _taskParams = _to getVariable "AI_taskParams";
	_taskParams params ["_target", "_searchRadius", "_timeout"];
	private _targetPos = _target;
	if(_targetPos isEqualType objNull) then	{
		_targetPos = getPos _target;
	};
	
	//Split vehicle groups if needed
	_gar call AI_fnc_splitVehicleGroups;
	
	//Arrays with different units and groups
	private _allVehicleHandles = [];
	private _allHumanHandles = [];
	private _allInfantryHandles = [];
	private _allGroupHandles = [];
	private _allVehGroupHandles = [];
	private _vehicleFSMArray = [];
	
	//Fill the arrays
	{
		private _groupHandle = [_gar, _x] call gar_fnc_getGroupHandle;
		_allGroupHandles pushBack _grouphandle;
		_groupHandle setBehaviour "AWARE"; //Set behaviour
		//If it's not a vehicle crew group
		if(([_gar, _x] call gar_fnc_getGroupType) != G_GT_veh_non_static) then
		{
			{
				_allInfantryHandles pushBack ([_gar, _x] call gar_fnc_getUnitHandle);
			} forEach ([_gar, _x] call gar_fnc_getGroupAliveUnits);
		}
		else
		{
			private _hg = [_gar, _x] call gar_fnc_getGroupHandle; //Group handle
			private _vehUnitData = ( ([_gar, _x] call gar_fnc_getGroupUnits) select {_x select 0 == T_VEH} ) select 0;
			private _vehHandle = [_gar, _vehUnitData] call gar_fnc_getUnitHandle;
			_allVehGroupHandles pushBack _hg;
			_vehicleFSMArray pushBack [_hg, _vehHandle, ["INIT", true]]; //[0: group handle, 1: vehicle handle, 2: state array]
			_vehHandle limitSpeed 666666; //Unlimited speed
			_allVehicleHandles pushBack _vehHandle;
		};
	} forEach (_gar call gar_fnc_getAllGroups);
	
	//Get array with all humans
	{
		_allHumanHandles pushBack ([_gar, _x] call gar_fnc_getUnitHandle);
	} forEach ([_gar, T_INF, -1] call gar_fnc_findUnits);
	
	//Find crew of vehicles that can't shoot
	for "_i" from 0 to ((count _allVehicleHandles) - 1) do
	{
		private _vehHandle = _allVehicleHandles select _i;
		private _fullCrew = _vehHandle call misc_fnc_getFullCrew;
		if(count (_fullCrew select 2) == 0) then //If there are no turrets
		{
			//Dismount and go fight!
			_allInfantryHandles append [assignedDriver _vehHandle];
		};
	};
	
	//If there is any infantry to dismount
	if (count _allInfantryHandles > 0) then {
		#ifdef DEBUG
		diag_log "fn_SAD.sqf: waiting for troops to dismount!";
		#endif
		//Order vehicles with troops to dismount
		{
			private _wp0 = _x addWaypoint [getPos leader _x, 8];
			_wp0 setWaypointType "MOVE";
			_x setCurrentWaypoint _wp0;
		} forEach _allVehGroupHandles;
		
		//Infantry, dismount!
		_allInfantryHandles orderGetIn false;
		{
			unassignVehicle _x;
		} forEach _allInfantryHandles;
		
		sleep 10;
	};
	
	//Make some waypoints for groups
	_allGroupHandles call AI_fnc_deleteAllWaypoints;
	//Infantry waypoints
	{
		//Set combat mode
		_x setCombatMode "RED";
		_x allowFleeing 0;
		//Add waypoints
		private _wp0 = _x addWaypoint [_targetPos, 10];
		_wp0 setWaypointCompletionRadius 0.2*_searchRadius;
		_wp0 setWaypointType "MOVE";
		//Generate random waypoints
		private _i = 1;
		while {_i < 6} do
		{
			private _wp = _x addWaypoint [_targetPos, _searchRadius];
			_wp setWaypointCompletionRadius 0.2*_searchRadius;
			_wp setWaypointType "MOVE";
			_i = _i + 1;
		};
		//Finally add a cycle waypoint
		private _wpcycle = _x addWaypoint [waypointPosition _wp0, 5];
		_wpcycle setWaypointType "CYCLE";
		_x setCurrentWaypoint _wp0;
	} forEach (_allGroupHandles - _allVehGroupHandles);
	
	private _run = true;
	private _t = time;
	private _tPrev = time;
	private _timeSafe = 0;
	//Start a loop
	while {_run && (_to getVariable "so_run")} do
	{
		//Time spent since previous iteration
		_dt = time - _tPrev;
		_tPrev = time;
		
		//Check if all the units have been destroyed
		if ({alive _x} count _allHumanHandles == 0) exitWith
		{
			_to setVariable ["AI_taskState", "FAILURE"];
			_to setVariable ["AI_failReason", "DESTROYED"];
			_run = false;
		};
		
		//Check states of all groups
		private _i = 0;
		while {_i < count _vehicleFSMArray} do {
			private _a = _vehicleFSMArray select _i;
			diag_log format ["input state array: %1", _a];
			private _stateArray = [_to, _a select 0, _a select 1, _a select 2] call AI_fnc_task_SAD_vehicleGroupFSM; //Group handle, vehicle handle, state array
			diag_log format ["_stateArray: %1", _stateArray];
			private _state = _stateArray select 0;
			//Check if this group has been destroyed or vehicle is not operational any more
			if (_state == "FAILURE") then {
				//Stop the FSM for this vehicle
				_vehicleFSMArray deleteAt _i;
			} else {
				//Store the new state
				_a set [2, _stateArray];
				_i = _i + 1;
			};	
		};
		
		//Check behaviour of groups
		private _combat = false;
		{
			if (behaviour (leader _x) == "COMBAT") exitWith
			{ _combat = true; };
		} forEach _allGroupHandles;
		//Is any group in combat mode?
		if (_combat) then
		{
			_timeSafe = 0; //Reset the timer
			diag_log "fn_SAD.sqf: groups are in COMBAT mode!";
		}
		else
		{
			_timeSafe = _timeSafe + _dt;
			diag_log format ["fn_SAD.sqf: groups have been safe for %1 seconds", _timeSafe];
			//If the groups have not seen enemies for more than specified time, call it a finished task
			if(_timeSafe > _timeout) then
			{
				_to setVariable ["AI_taskState", "SUCCESS"];
				_run = false;
			};
		};
		
		//Update position of the garrison
		_gar setPos (getPos leader (_allGroupHandles select 0));
		
		if(_run) then
		{
			//Update time variable
			_t = time + SLEEP_TIME;
			//SLeep and check if it's ordered to stop the thread
			waitUntil
			{
				sleep SLEEP_RESOLUTION;
				(time > _t) || (!(_to getVariable "so_run"))
			};
		};
	}; //while
};

//Return to scriptObject_start
_hScript
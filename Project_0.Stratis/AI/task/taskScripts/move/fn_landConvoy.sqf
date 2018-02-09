/*
Script for managing units in a convoy
*/

#define DEBUG
//#define DEBUG_FORMATION

//How much time has to pass until a new leader is assigned
#define STUCK_TIMER_LIMIT		25
//How much time has to pass until units get teleported into their vehicles
#define MOUNT_TIMER_LIMIT		50
#define DISMOUNT_TIMER_LIMIT	30
//Sleep interval
#define SLEEP_RESOLUTION 0.01
#define SLEEP_TIME 2

params ["_to"];

private _garTransport = _to getVariable "AI_garrison";
private _garsCargo = _garTransport call gar_fnc_getCargoGarrisons;
private _garCargo = if(count _garsCargo > 0) then
{
	_garsCargo select 0 //Now we support only transport of ONE cargo garrison
}
else
{ objNull };

//Form a single group for vehicles
[_garTransport, [_garTransport] + _garsCargo] call AI_fnc_formVehicleGroup;

//Assign all infantry as cargo
[_garTransport, _garsCargo] call AI_fnc_assignInfantryCargo;

private _vehGroupID = ([_garTransport, G_GT_veh_non_static] call gar_fnc_findGroups) select 0;

diag_log format ["====== land convoy: veh group ID: %1", _vehGroupID];

//Find all the vehicles
private _vehArray = [];
{
	if (_x select 0 == T_VEH) then
	{
		_vehArray pushBack ([_garTransport, _x] call gar_fnc_getUnitHandle);
	};
} forEach (_garTransport call gar_fnc_getAllUnits);

private _vehGroupHandle = [_garTransport, _vehGroupID] call gar_fnc_getGroupHandle;
diag_log format ["====== land convoy: veh group handle: %1", _vehGroupHandle];
_vehGroupHandle deleteGroupWhenEmpty false; //If all crew dies, inf groups might take their seats

//Spawn a script
private _hScript = [_to, _vehArray, _vehGroupHandle] spawn
{	
	//Read input parameters
	params ["_to", "_vehArray", "_vehGroupHandle"];
	
	//Read task parameters
	private _taskParams = _to getVariable "AI_taskParams";
	_taskParams params ["_dest", "_compRadius"];
	private _destPos = _dest;
	private _destType = 0;
	if (_dest isEqualType objNull) then
	{ //Destination is a location
		_destPos = getPos _dest;
		_destType = 1;
	};
	
	diag_log format ["==== land convoy destPos: %1", _destPos];
	
	//Read some variables
	private _garTransport = _to getVariable "AI_garrison";
	private _garsCargo = _garTransport call gar_fnc_getCargoGarrisons;
	private _garCargo = objNull;
	if(count _garsCargo > 0) then
	{
		_garCargo = _garsCargo select 0;
	};
	
	//Common variables
	private _allHumanHandles = []; //All humans
	private _allCrew = []; //All crew members
	
	//We need the power of the Finite State Machine!
	private _state = "INIT";
	private _stateChanged = true;
	private _speedMax = 60; //Maximum speed for the convoy
	private _speedLimit = 20; //The initial speed limit
	private _separation = 18; //Convoy needed separation in meters
	private _run = true;
	private _nCrew = count units _vehGroupHandle;
	private _nCrewPrev = _nCrew;
	private _timer = 0; //Timer showing for how long the convoy has been stuck
	private _t = time;
	private _tPrev = time;
	private _dt = 0;
	while {_run && (_to getVariable "so_run")} do
	{
		//Time spent since previous execution
		_dt = time - _tPrev;
		_tPrev = time;
		//Update common variables
		_allHumanHandles = _allHumanHandles select {alive _x};
		private _allVehiclesCanMove = ((count _vehArray) == ({canMove _x} count _vehArray));
		_nCrewPrev = _nCrew;
		_nCrew = {alive _x} count (units _vehGroupHandle);
		if(_stateChanged) then
		{
			_to setVariable ["AI_convoyState", _state, false]; //Update the state variable
		};
		
		//Update position of the garrison
		private _leaderPos = getPos leader _vehGroupHandle;
		_garTransport setPos _leaderPos;
		{
			_x setPos _leaderPos;
		} forEach _garsCargo;
		
		//Check states
		switch (_state) do
		{
			//==== The initial state ====
			//Reorganize the vehicle group and its crew
			case "INIT":
			{
				diag_log "AI_fnc_task_move_landConvoy: entered INIT state";
				
				//Remove non functional vehicles from the convoy
				private _vehToRemove = _vehArray select {!canMove _x};
				if (count _vehToRemove != 0) then
				{
					_vehArray = _vehArray - _vehToRemove;
					diag_log format ["INFO: fn_landConvoy.sqf: removing vehicles that can't move: %1", _vehToRemove];
					[_garTransport, _vehToRemove] call AI_fnc_landConvoy_removeVehicles;
				};
				
				//Repair broken squads (for some reason units might leave their squads into empty squads)
				private _n = (_garTransport call AI_fnc_rejoinGarrisonGroup);
				#ifdef DEBUG
				if(_n > 0) then
				{
					diag_log format ["INFO: fn_landConvoy.sqf: %1 units have rejoined their group", _n];
				};
				#endif
				
				//Try to find crew for all vehicles
				diag_log "INFO: fn_landConvoy.sqf: reorganizing crew";
				[_garTransport, [_garTransport] + _garsCargo] call AI_fnc_formVehicleGroup;
				
				//Update common variables
				_allHumanHandles = [];
				{
					_allHumanHandles pushBack ([_garCargo, _x] call gar_fnc_getUnitHandle);
				} forEach ([_garCargo, T_INF, -1] call gar_fnc_findUnits);
				//Get array of infantry units from transport garrison
				{
					_allHumanHandles pushBack ([_garTransport, _x] call gar_fnc_getUnitHandle);
				} forEach ([_garTransport, T_INF, -1] call gar_fnc_findUnits);
				_allCrew = units _vehGroupHandle;
				_nCrew = count units _vehGroupHandle;
				_nCrewPrev = _nCrew;
				
				//Remove vehicles without a driver from the convoy
				private _vehToRemove = _vehArray select {!alive (assignedDriver _x)};
				if (count _vehToRemove != 0) then
				{
					_vehArray = _vehArray - _vehToRemove;
					diag_log format ["INFO: fn_landConvoy.sqf: removing vehicles without drivers: %1", _vehToRemove];
					[_garTransport, _vehToRemove] call AI_fnc_landConvoy_removeVehicles;
				};
				
				call
				{
					//Check if the cargo has been destroyed
					if(!isNull _garCargo && (_garCargo call gar_fnc_countAllUnits) == 0) exitWith
					{
						//We've lost all cargo!
						_to setVariable ["AI_taskState", "FAILURE"];
						_to setVariable ["AI_failReason", "NO_CARGO"];
						[_garTransport, _garCargo] call gar_fnc_removeCargoGarrison;
						_run = false; //Stop the loop
					};
					
					//Check if the convoy has been destroyed
					if(count _vehArray == 0) exitWith
					{
						_to setVariable ["AI_taskState", "FAILURE"];
						_to setVariable ["AI_failReason", "NO_TRANSPORT"];
						[_garTransport, _garCargo] call gar_fnc_removeCargoGarrison;
						_run = false; //Stop the loop
					};
					
					//Check if everything has been destroyed
					if((_garTransport call gar_fnc_countAllUnits) == 0) exitWith
					{
						_to setVariable ["AI_taskState", "FAILURE"];
						_to setVariable ["AI_failReason", "DESTROYED"];
						[_garTransport, _garCargo] call gar_fnc_removeCargoGarrison;
						_run = false; //Stop the loop
					};
					
					//Check if cargo can still be transported
					if(!isNull _garCargo) exitWith
					{
						if(!([_garTransport, [_garCargo]] call gar_fnc_canLoadCargo)) exitWith
						{
							_to setVariable ["AI_taskState", "FAILURE"];
							_to setVariable ["AI_failReason", "NO_TRANSPORT"];
							[_garTransport, _garCargo] call gar_fnc_removeCargoGarrison;
							_run = false;
						}
					};
					
					//Check if the convoy has arrived
					if([_vehGroupHandle, _compRadius, _dest, _destType] call AI_fnc_landConvoy_arrived) exitWith
					{
						diag_log format ["AI_fnc_task_move_landConvoy: convoy has arrived before MOVE!"];
						_to setVariable ["AI_taskState", "SUCCESS", false];
						_run = false; //Stop the loop
					};
					
					switch (behaviour leader _vehGroupHandle) do
					{
						case "COMBAT":
						{
							_state = "COMBAT";
							_stateChanged = true;
						};
						default
						{
							_state = "MOUNT";
							_stateChanged = true;
						};
					};
				};
			};
			
			//==== State for mounting vehicles ====
			case "MOUNT":
			{
				if (_stateChanged) then
				{
					diag_log "AI_fnc_task_move_landConvoy: entered MOUNT state";
					//Order drivers of unarmed vehicles to stop so that infantry can mount
					_vehGroupHandle call AI_fnc_deleteAllWaypoints;
					private _wp0 = _vehGroupHandle addWaypoint [getPos leader _vehGroupHandle, 5];
					_wp0 setWaypointType "MOVE";
					doStop (units _vehGroupHandle);
					_timer = 0;
					_stateChanged = false;
				};
				
				//Reassign infantry units as cargo every tick to resolve conflicts
				[_garTransport, _garsCargo] call AI_fnc_assignInfantryCargo;
				_allHumanHandles orderGetIn true;
				
				//Check if someone has got stuck somewhere and can't get in
				_timer = _timer + _dt;
				#ifdef DEBUG
				diag_log format ["fn_landConvoy.sqf: MOUNT state timer: %1", _timer];
				#endif
				private _nHumansInVeh = {vehicle _x != _x} count _allHumanHandles;
				//Only teleport them when someone has already boarded the vehicle
				if (_timer > MOUNT_TIMER_LIMIT && (_nHumansInVeh >= ceil (0.5*(count _allHumanHandles)) )) then
				{
					//For fuck's sake why did you get stuck??
					private _humansOnFoot =  _allHumanHandles select {vehicle _x isEqualTo _x};
					#ifdef DEBUG
					diag_log format ["fn_landConvoy.sqf: teleporting infantry into vehicles: %1", _humansOnFoot];
					#endif
					_humansOnFoot call AI_fnc_moveInAssigned;
				};
				
				//==== Check transition conditions ====
				call
				{
					//Check behaviour
					private _beh = behaviour (leader _vehGroupHandle);
					#ifdef DEBUG
						diag_log format ["AI_fnc_task_move_landConvoy.sqf: behaviour: %1", _beh];
					#endif
					if (_beh == "COMBAT") exitWith
					{
						_state = "DISMOUNT";
						_stateChanged = true;
					};
					
					//Check if crew composition has changed
					//or if some vehicles are not operational any more
					if(_nCrew != _nCrewPrev || ({!canMove _x} count _vehArray != 0)) exitWith
					{
						#ifdef DEBUG
						diag_log format ["fn_landConvoy.sqf: _nCrewPrev: %1, _nCrew: %2, _nVehCantMove: %3",
						                 	_nCrewPrev, _nCrew, {!canMove _x} count _vehArray];
						#endif
						_state = "DISMOUNT_ALL";
						_stateChanged = true;
					};
					
					//Check if all the infantry has boarded their vehicles
					diag_log format ["AI_fnc_task_move_landConvoy: waiting for units to get in: %1 / %2", _nHumansInVeh, count _allHumanHandles];
					if(count _allHumanHandles == _nHumansInVeh ) exitWith
					{
						//Switch to "MOVE" state
						_state = "MOVE";
						_stateChanged = true;
					};
				};
			};
			
			case "DISMOUNT_ALL":
			{
				if (_stateChanged) then
				{
					diag_log format ["AI_fnc_task_move_landConvoy: entered DISMOUNT_ALL state"];
					_vehGroupHandle call AI_fnc_deleteAllWaypoints;
					private _wp0 = _vehGroupHandle addWaypoint [getPos leader _vehGroupHandle, 15, 0, "Hold"];
					_wp0 setWaypointType "MOVE";
					_vehGroupHandle setCurrentWaypoint _wp0;
					_stateChanged = false;
					_timer = 0;
				};
				
				//Order all units to dismount
				{unassignVehicle _x;} forEach _allHumanHandles;
				_allHumanHandles orderGetIn false;
				
				//Check if someone has got stuck somewhere and can't get out
				_timer = _timer + _dt;
				#ifdef DEBUG
				diag_log format ["fn_landConvoy.sqf: DISMOUNT_ALL state timer: %1", _timer];
				#endif
				if (_timer > DISMOUNT_TIMER_LIMIT) then
				{
					private _humansOnFoot =  _allHumanHandles select {vehicle _x isEqualTo _x};
					#ifdef DEBUG
					diag_log format ["fn_landConvoy.sqf: force dismounting all humans!", _humansOnFoot];
					#endif
					{moveOut _x;} forEach _allHumanHandles;
				};

				//Check if all the infantry has dismounted
				private _nHumansOnFoot = {vehicle _x == _x} count _allHumanHandles;
				diag_log format ["AI_fnc_task_move_landConvoy: waiting for units to get out: %1 / %2", _nHumansOnFoot, count _allHumanHandles];
				if(count _allHumanHandles == _nHumansOnFoot) then
				{
					//Switch to "COMBAT" state
					switch (behaviour leader _vehGroupHandle) do
					{
						case "COMBAT":
						{
							_state = "COMBAT";
							_stateChanged = true;
						};
						default
						{
							_state = "INIT";
							_stateChanged = true;
						};
					};
				};
			};
			
			case "MOVE":
			{
				//If the convoy was requested to change its destination
				/*
				if (_scriptObject getVariable "AI_destPosChanged") then
				{
					//Then set the _stateChanged flag to force add new waypoint
					_destPos = _scriptObject getVariable "AI_newDestPos";
					diag_log format ["AI_fnc_task_move_landConvoy: destination position has been changed to: %1", _destPos];
					_scriptObject setVariable ["AI_destPosChanged", false, false];
					_stateChanged = true;
				};
				*/
				
				if (_stateChanged) then
				{
					diag_log "AI_fnc_task_move_landConvoy: entered MOVE state";
					_vehGroupHandle call AI_fnc_deleteAllWaypoints;
					//Add new waypoint
					/*
					private _wp0 = _vehGroupHandle addWaypoint [getPos leader _vehGroupHandle, 15, 0, ""];
					_wp0 setWaypointType "MOVE";
					_wp0 setWaypointCompletionRadius 20;
					_vehGroupHandle setCurrentWaypoint _wp0;
					*/
					
					units _vehGroupHandle doFollow (leader _vehGroupHandle);
					private _wp1 = _vehGroupHandle addWaypoint [_destPos, 2]; // 0, "Destination"]; //[center, radius, index, name]
					_wp1 setWaypointType "MOVE";
					_wp1 setWaypointCompletionRadius 20;
					//_vehGroupHandle setCurrentWaypoint _wp1;
					
					/*{
						diag_log format [" ===== waypoint: %1 pos: %2", _x, waypointPosition _x];
					} forEach (waypoints _vehGroupHandle); */
					
					//Set convoy separation
					{
						private _vehHandle = _x;
						_vehHandle limitSpeed 666666; //Set the speed of all vehicles to unlimited
						_vehHandle setConvoySeparation _separation;
						//_vehHandle forceFollowRoad true;
					} forEach _vehArray;
					//Limit the speed of the leading vehicle
					(vehicle (leader _vehGroupHandle)) limitSpeed _speedLimit; //Speed in km/h
					//Set behaviour
					_vehGroupHandle setBehaviour "SAFE";
					_vehGroupHandle setBehaviour "GREEN"; //Hold fire and keep formation
					//Reset the timer
					_timer = 0;
					_stateChanged = false;
				};
				
				//Check the separation of the convoy
				private _sCur = [_vehArray, vehicle leader _vehGroupHandle] call AI_fnc_landConvoy_getMaxSeparation; //The current maximum separation between vehicles
				#ifdef DEBUG_FORMATION
				diag_log format [">>> Current separation: %1", _sCur];
				#endif
				if(_sCur > 1.9*_separation) then
				{
					//We are driving too fast!
					if(_speedLimit > 15) then
					{
						_speedLimit = _speedLimit - 3;
						(vehicle (leader _vehGroupHandle)) limitSpeed _speedLimit;
						#ifdef DEBUG_FORMATION
						diag_log format [">>> Slowing down! New speed: %1", _speedLimit];
						#endif
					};
				}
				else
				{
						//We are driving too slow!
						if(_speedLimit < _speedMax) then
						{
							_speedLimit = _speedLimit + 3.5;
							(vehicle (leader _vehGroupHandle)) limitSpeed _speedLimit;
							#ifdef DEBUG_FORMATION
							diag_log format [">>> Accelerating! New speed: %1", _speedLimit];
							#endif
						};
				};
				
				//Check if the convoy has stuck
				if(speed leader _vehGroupHandle < 6) then
				{
					_timer = _timer + _dt;
					#ifdef DEBUG
					diag_log format ["fn_landConvoy.sqf: convoy has been static for %1 seconds!", _timer];
					#endif
					if(_timer > STUCK_TIMER_LIMIT) then
					{
						#ifdef DEBUG
						diag_log format ["fn_landConvoy.sqf: Convoy has stuck! Selecting a new leader!", _timer];
						#endif
						_vehGroupHandle selectLeader (selectRandom (units _vehGroupHandle));
						_stateChanged = true; //Reenter this state to reset the waypoints
						_timer = 0;
					};
				}
				else
				{
					_timer = 0;
				};
				
				//Debug
				/*
				#ifdef DEBUG
				private _allCrewGroups = [];
				{
					_allCrewGroups pushBack (group _x);
				} forEach _allCrew;
				diag_log format ["All crew groups: %1", _allCrewGroups];
				#endif
				*/
				
				//Change state if needed
				call
				{
					//Check if the convoy has arrived
					private _arrived = [_vehGroupHandle, _compRadius, _dest, _destType] call AI_fnc_landConvoy_arrived;
					if(_arrived) then
					{
						diag_log format ["AI_fnc_task_move_landConvoy: convoy has arrived"];
						{
							private _vehHandle = _x;
							_vehHandle setConvoySeparation 10; //Make them stay a bit closer when they arrive
						} forEach _vehArray;
						_to setVariable ["AI_taskState", "SUCCESS", false];
						_run = false; //Stop the loop
					};
					
					//Check the behaviour of the group
					private _beh = behaviour (leader _vehGroupHandle);
					#ifdef DEBUG
						diag_log format ["AI_fnc_task_move_landConvoy.sqf: behaviour: %1", _beh];
					#endif
					if (_beh == "COMBAT") exitWith
					{
						_state = "DISMOUNT";
						_stateChanged = true;
					};
					
					//Check if crew composition has been changed
					if(_nCrew != _nCrewPrev || ({!canMove _x} count _vehArray != 0)) exitWith
					{
						#ifdef DEBUG
						diag_log format ["fn_landConvoy.sqf: _nCrewPrev: %1, _nCrew: %2, _nVehCantMove: %3",
						                 	_nCrewPrev, _nCrew, {!canMove _x} count _vehArray];
						#endif
						_state = "DISMOUNT_ALL"; //Dismount then reorganize
						_stateChanged = true;
					};
					
					//Check that all the units are inside their vehicles
					private _nHumansInVeh = {vehicle _x != _x} count _allHumanHandles;
					if(count _allHumanHandles != _nHumansInVeh) exitWith
					{
						//Just why the hell did you jump out???
						#ifdef DEBUG
							diag_log "AI_fns_landConvoy: not all units are in vehicles during MOVE state!";
						#endif
						_state = "MOUNT";
						_stateChanged = true;
						//TODO if the moron driver has flipped his vehicle over(yes, they can), unflip it
					};
				};
			};
			
			case "DISMOUNT":
			{
				if (_stateChanged) then
				{
					diag_log format ["AI_fnc_task_move_landConvoy: entered DISMOUNT state"];
					_vehGroupHandle call AI_fnc_deleteAllWaypoints;
					private _wp0 = _vehGroupHandle addWaypoint [getPos leader _vehGroupHandle, 15, 0, "Hold"];
					_wp0 setWaypointType "MOVE";
					_vehGroupHandle setCurrentWaypoint _wp0;
					//Order drivers of all vehicles to stop
					{
						private _vehHandle = _x;
						if(count (assignedCargo _vehHandle) != 0) then //If this vehicle is carrying an infantry group
						{
							doStop (assignedDriver _vehHandle);
						};
					} forEach _vehArray;
					_stateChanged = false;
					_timer = 0;
				};
				
				//Order infantry units to dismount
				private _humansToDismount = _allHumanHandles - _allCrew;
				/*
				private _humansToDismount = [];
				//Order drivers of vehicles without gunners to dismount
				for "_i" from 0 to ((count _vehArray) - 1) do
				{
					private _vehHandle = _vehArray select _i;
					private _fullCrew = _vehHandle call misc_fnc_getFullCrew;
					if(count (_fullCrew select 2) == 0) then //If there are no turrets
					{
						//Dismount and go fight!
						_humansToDismount append (_allHumanHandles select {assignedVehicle _x isEqualTo _vehHandle});
					};
				};
				*/
				{unassignVehicle _x;} forEach _humansToDismount; //Unassign their vehicles so that they don't use them in fight
				_humansToDismount orderGetIn false;
				
				//Check if someone has got stuck somewhere and can't dismount
				_timer = _timer + _dt;
				#ifdef DEBUG
				diag_log format ["fn_landConvoy.sqf: DISMOUNT_ALL state timer: %1", _timer];
				#endif
				if (_timer > DISMOUNT_TIMER_LIMIT) then
				{
					private _humansOnFoot =  _allHumanHandles select {vehicle _x isEqualTo _x};
					#ifdef DEBUG
					diag_log format ["fn_landConvoy.sqf: force dismounting infantry!", _humansOnFoot];
					#endif
					{moveOut _x;} forEach _humansToDismount;
				};

				//Check if all the infantry has dismounted
				private _nHumansOnFoot = {vehicle _x == _x} count _humansToDismount;
				diag_log format ["AI_fnc_task_move_landConvoy: waiting for units to get out: %1 / %2", _nHumansOnFoot, count _humansToDismount];
				if(_nHumansOnFoot == count _humansToDismount) then
				{
					//Switch to "COMBAT" state
					_state = "COMBAT";
					_stateChanged = true;
				};
			};
			
			case "COMBAT":
			{
				if (_stateChanged) then
				{
					diag_log "AI_fnc_task_move_landConvoy: entered COMBAT state";					
					units _vehGroupHandle doFollow (leader _vehGroupHandle); //After infantry has dismounted, vehicles can engage
					_stateChanged = false;
				};
				private _beh = behaviour (leader _vehGroupHandle);
				#ifdef DEBUG
					diag_log format ["AI_fnc_task_move_landConvoy.sqf: behaviour: %1", _beh];
				#endif
				if (_beh == "AWARE" || _beh == "ERROR") then //ERROR behaviour - when there is noone in the group
				{
					//Switch to INIT state to recheck the composition in case of losses
					_state = "INIT";
					_stateChanged = true;
				};
			};
		}; //switch
		
		if (_run) then
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
}; //spawn

//Return the script handle
_hScript

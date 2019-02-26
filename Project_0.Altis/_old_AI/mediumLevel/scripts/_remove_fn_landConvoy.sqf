/*
Script for managine units in a convoy

_extraParams:
	[_armedVehGroups, _unarmedVehGroups, _destPos]
		_armedVehGroups - array of [_vehUnitData, _crewUnitData, _infGroupID] per every vehicle that can shoot with crew:
			_vehGroupID - _groupID of the vehicle group
			_infGroupID - the groupID of the infantry this vehicle is carrying, or -1 if it carries no inf. groups
		_unarmedVehGroups - the same as _armedVehArray but for vehicles that can't shoot (trucks, ...)
		_destPos - the position of the destination
		
	//TODO: add management of killed units and damaged vehicles. Add reallocation of units from a broken vehicle to a new one.
*/

#define DEBUG

params ["_scriptObject", "_extraParams"];

//Reorganize the convoy garrison
_extraParams params ["_armedVehGroups", "_unarmedVehGroups", "_destPos"];
#ifdef DEBUG
	diag_log format ["AI_fnc_landConvoy.sqf: _armedVehGroups: %1, _unarmedVehGroups: %2", _armedVehGroups, _unarmedVehGroups];
#endif
//Read other things
private _gar = (_scriptObject getVariable ["AI_garrisons", objNull]) select 0;

//Set variables of the object
_scriptObject setVariable ["AI_convoyState", "MOUNT", false];
_scriptObject setVariable ["AI_destPosChanged", false, false];

//Merge the vehicle groups into one VEHICLE-MEGA-GROUP!
//Create a new group
private _rarray = [];
private _rid = [_gar, G_GT_veh_non_static, _rarray] call gar_fnc_addNewEmptyGroup;
waitUntil {sleep 0.01; [_gar, _rid] call gar_fnc_requestDone};
private _vehGroupID = _rarray select 0;

//Fill arrays and move vehicles and their crew to the new group
private _armedVehArray =[]; //[]
private _unarmedVehArray = []; //[]
{ // forEach _armedVehGroups
	private _groupUnits = ([_gar, _x select 0] call gar_fnc_getGroupUnits);
	//Get vehicle unit handle
	private	_vehUnitData = _groupUnits select 0;
	private _vehUnitHandle = [_gar, _vehUnitData] call gar_fnc_getUnitHandle;
	//Get crew unit handles
	private _crewUnitData = _groupUnits - [_vehUnitData];
	private _crewUnitHandles = [];
	{
		_crewUnitHandles pushBack ([_gar, _x] call gar_fnc_getUnitHandle);
	} forEach _crewUnitData;
	//Get infantry group handle
	private _infGroupID = _x select 1;
	private _infGroupHandle = if(_infGroupID != -1) then
	{ [_gar, _infGroupID] call gar_fnc_getGroupHandle; } else { grpNull };
	_armedVehArray pushBack [_vehUnitHandle, _crewUnitHandles, _infGroupHandle];
	{ //forEach _groupUnits;
		[_gar, _x, _vehGroupID, false] call gar_fnc_joinGroup;
	} forEach _groupUnits;
} forEach _armedVehGroups;
private _rid = 0;
{ // forEach _unarmedVehGroups
	private _groupUnits = ([_gar, _x select 0] call gar_fnc_getGroupUnits);
	//Get vehicle unit handle
	private	_vehUnitData = _groupUnits select 0;
	private _vehUnitHandle = [_gar, _vehUnitData] call gar_fnc_getUnitHandle;
	//Get crew unit handles
	private _crewUnitData = _groupUnits - [_vehUnitData];
	private _crewUnitHandles = [];
	{
		_crewUnitHandles pushBack ([_gar, _x] call gar_fnc_getUnitHandle);
	} forEach _crewUnitData;
	//Get infantry group handle
	private _infGroupID = _x select 1;
	private _infGroupHandle = if(_infGroupID != -1) then
	{ [_gar, _infGroupID] call gar_fnc_getGroupHandle; } else { grpNull };
	_unarmedVehArray pushBack [_vehUnitHandle, _crewUnitHandles, _infGroupHandle];
	{ //forEach _groupUnits;
		_rid = [_gar, _x, _vehGroupID, false] call gar_fnc_joinGroup;
	} forEach _groupUnits;
} forEach _unarmedVehGroups;
//Wait until the last request is finished
waitUntil {sleep 0.01; [_gar, _rid] call gar_fnc_requestDone};

private _vehGroupHandle = [_gar, _vehGroupID] call gar_fnc_getGroupHandle;
_vehGroupHandle deleteGroupWhenEmpty false; //If all crew dies, inf groups might take their seats

//Spawn a script
private _hScript = [_scriptObject, _vehGroupHandle, _armedVehArray, _unarmedVehArray, _destPos] spawn
{
	//==== Some fonctions ====
	_getUnitHandles =
	{
		/*
		A function that helps manage _armedVehGroups and _unarmedVehGroups.
		It is only used from the fn_landConvoy.
		*/
		params ["_vehData", "_getCrew", "_getPassengers"];

		private _vehHandle = _vehData select 0;
		private _crewHandles = [];
		private _infHandles = [];
		//Check if the vehicle can actually move
		if(canMove _vehHandle) then
		{
			_crewHandles = if(_getCrew) then {_vehData select 1} else {[]};
			_infHandles = if(_getPassengers) then {units(_vehData select 2)} else {[]};
		}
		else
		{
			_crewHandles = [];
			_infHandles = [];
		};
		private _unitHandles = _crewHandles + _infHandles;
		
		_unitHandles
	};

	_getMaxSeparation =
	{
		params ["_vehGroupHandle"];
		//Ger vehicles in formation order
		private _allVehicles = [];
		{
			_allVehicles pushBackUnique (vehicle _x);
		} forEach (formationMembers (leader _vehGroupHandle));
		//Get the max separation
		private _dMax = 0;
		private _c = count _allVehicles;
		for "_i" from 0 to (_c - 2) do
		{
			_d = (_allVehicles select _i) distance (_allVehicles select (_i + 1));
			if (_d > _dMax) then {_dMax = _d;};
		};
		_dMax
	};
	//=================================
	
	
	//Read input parameters
	params ["_scriptObject", "_vehGroupHandle", "_armedVehArray", "_unarmedVehArray", "_destPos"];
	
	#ifdef DEBUG
		diag_log format ["AI_fnc_landConvoy.sqf: _armedVehArray: %1, _unarmedVehArray: %2", _armedVehArray, _unarmedVehArray];
	#endif
	
	//We need the power of the Finite State Machine!
	private _state = "MOUNT";
	private _stateChanged = true;
	private _speedMax = 60; //Maximum speed for the convoy
	private _speedLimit = 20; //The initial speed limit
	private _separation = 27; //Convoy separation in meters
	while {true} do
	{
		sleep 2;
		if(_stateChanged) then
		{
			_scriptObject setVariable ["AI_convoyState", _state, false]; //Update the state variable
		};
		switch (_state) do
		{
			case "MOUNT":
			{
				if (_stateChanged) then
				{
					diag_log "AI_fnc_landConvoy: entered MOUNT state";
					//Order drivers of unarmed vehicles to stop so that infantry can mount
					doStop (units _vehGroupHandle);
					_stateChanged = false;
				};
				
				//Order the crew to get in
				private _infAndCrewHandles = [];
				{
					private _crewHandles = [_x, true, false] call _getUnitHandles;
					private _passHandles = [_x, false, true] call _getUnitHandles;
					private _vehHandle = _x select 0;
					if(count _passHandles > 0) then
					{
						//Cargo seats can be FFVs, in which case they are actually turrets, not cargo seats!
						private _fullCrew = _vehHandle call misc_fnc_getFullCrew;
						private _psgTurrets = _fullCrew select 3;
						private _npt = count _psgTurrets;
						private _nCargo = _fullCrew select 4;
						{
							//First assign units as FFV turrets, then as cargo
							if (_forEachIndex < _npt) then
							{ _x assignAsTurret [_vehHandle, _psgTurrets select _forEachIndex]; } else
							{ _x assignAsCargo _vehHandle; };
						} forEach _passHandles;
					};
					_infAndCrewHandles append _crewHandles;
					_infAndCrewHandles append _passHandles;
				} forEach (_armedVehArray + _unarmedVehArray);
				_infAndCrewHandles orderGetIn true;
				
				//Check if all the infantry has boarded their vehicles
				private _infAndCrewInVehHandles = _infAndCrewHandles select {!(vehicle _x isEqualTo _x)};
				diag_log format ["AI_fnc_landConvoy: waiting for units to get in: %1 / %2", count _infAndCrewInVehHandles, count _infAndCrewHandles];
				//Also check behaviour
				private _beh = behaviour (leader _vehGroupHandle);
				#ifdef DEBUG
					diag_log format ["AI_fnc_landConvoy.sqf: behaviour: %1", _beh];
				#endif
				call
				{
					if (_beh == "COMBAT") exitWith
					{
						_state = "DISMOUNT";
						_stateChanged = true;
					};
					if(count _infAndCrewInVehHandles == count _infAndCrewHandles) exitWith
					{
						//Switch to "MOVE" state
						_state = "MOVE";
						_stateChanged = true;
					};
				};

			};
			case "MOVE":
			{
				//If the convoy was requested to change its destination
				if (_scriptObject getVariable "AI_destPosChanged") then
				{
					//Then set the _stateChanged flag to force add new waypoint
					_destPos = _scriptObject getVariable "AI_newDestPos";
					diag_log format ["AI_fnc_landConvoy: destination position has been changed to: %1", _destPos];
					_scriptObject setVariable ["AI_destPosChanged", false, false];
					_stateChanged = true;
				};
				if (_stateChanged) then
				{
					diag_log "AI_fnc_landConvoy: entered MOVE state";
					units _vehGroupHandle doFollow (leader _vehGroupHandle);
					while {(count (waypoints _vehGroupHandle)) > 0} do
					{
						deleteWaypoint [_vehGroupHandle, ((waypoints _vehGroupHandle) select 0) select 1];
					};
					//Add new waypoint
					private _wp0 = _vehGroupHandle addWaypoint [_destPos, 0, 0, "Destination"]; //[center, radius, index, name]
					_wp0 setWaypointType "MOVE";
					_vehGroupHandle setCurrentWaypoint _wp0;
					//Set convoy separation
					{
						private _vehHandle = _x select 0;
						_vehHandle limitSpeed 666666; //Set the speed of all vehicles to unlimited
						_vehHandle setConvoySeparation _separation;
						//_vehHandle forceFollowRoad true;
					} forEach (_armedVehArray + _unarmedVehArray);
					//Limit the speed of the leading vehicle
					(vehicle (leader _vehGroupHandle)) limitSpeed _speedLimit; //Speed in km/h
					_stateChanged = false;
				};
				
				//Check the separation of the convoy
				private _sCur = [_vehGroupHandle] call _getMaxSeparation; //The current maximum separation between vehicles
				//diag_log format ["Current separation: %1", _sCur];
				if(_sCur > 1.7*_separation) then
				{
					//We are driving too fast!
					if(_speedLimit > 15) then
					{
						_speedLimit = _speedLimit - 3;
						(vehicle (leader _vehGroupHandle)) limitSpeed _speedLimit;
						//diag_log format ["Slowing down! New speed: %1", _speedLimit];
					};
				}
				else
				{
						//We are driving too slow!
						if(_speedLimit < _speedMax) then
						{
							_speedLimit = _speedLimit + 2;
							(vehicle (leader _vehGroupHandle)) limitSpeed _speedLimit;
							//diag_log format ["Accelerating! New speed: %1", _speedLimit];
						};
				};
				
				//Change state if needed
				call
				{
					//Check if the convoy has arrived
					if (((leader _vehGroupHandle) distance2D _destPos) < 50) then //Are we there yet??
					{
						_state = "ARRIVAL";
						_stateChanged = true;
					};
					//Check the behaviour of the group
					private _beh = behaviour (leader _vehGroupHandle);
					#ifdef DEBUG
						diag_log format ["AI_fnc_landConvoy.sqf: behaviour: %1", _beh];
					#endif
					if (_beh == "COMBAT") exitWith
					{
						_state = "DISMOUNT";
						_stateChanged = true;
					};
					//Check that all the units are inside their vehicles
					private _infAndCrewHandles = [];
					{
						_infAndCrewHandles append ([_x, true, true] call _getUnitHandles);
					} forEach (_armedVehArray + _unarmedVehArray);
					private _infAndCrewInVehHandles = _infAndCrewHandles select {!(vehicle _x isEqualTo _x)};
					if(count _infAndCrewInVehHandles != count _infAndCrewHandles) exitWith
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
					diag_log format ["AI_fnc_landConvoy: entered DISMOUNT state"];
					while {(count (waypoints _vehGroupHandle)) > 0} do
					{
						deleteWaypoint [_vehGroupHandle, ((waypoints _vehGroupHandle) select 0) select 1];
					};
					private _wp0 = _vehGroupHandle addWaypoint [getPos leader _vehGroupHandle, 15, 0, "Hold"];
					_wp0 setWaypointType "MOVE";
					_vehGroupHandle setCurrentWaypoint _wp0;
					_stateChanged = false;
					//Order drivers of all vehicles to stop
					{
						private _vehHandle = _x select 0;						
						//_vehHandle forceFollowRoad false;
						if(!isNull (_x select 2)) then //If this vehicle is carrying an infantry group
						{
							private _crewHandles = [_x, true, false] call _getUnitHandles;
							doStop _crewHandles;
						};
					} forEach (_unarmedVehArray + _armedVehArray);
				};
				
				//Order infantry units to dismount
				private _infHandles = [];
				{ //Dismount passengers of armed vehicles
					_infHandles append ([_x, false, true] call _getUnitHandles);
				} forEach _armedVehArray;
				{ //Dismount drivers and passengers of unarmed vehicles
					_infHandles append ([_x, true, true] call _getUnitHandles);
				} forEach _unarmedVehArray;
				_infHandles orderGetIn false;

				//Check if all the infantry has dismounted
				private _infOnFootHandles = _infHandles select {(vehicle _x) isEqualTo _x};
				diag_log format ["AI_fnc_landConvoy: waiting for units to get out: %1 / %2", count _infOnFootHandles, count _infHandles];
				if(count _infOnFootHandles == count _infHandles) then
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
					diag_log "AI_fnc_landConvoy: entered COMBAT state";
					_stateChanged = false;
				};
				private _beh = behaviour (leader _vehGroupHandle);
				#ifdef DEBUG
					diag_log format ["AI_fnc_landConvoy.sqf: behaviour: %1", _beh];
				#endif
				if (_beh == "AWARE") then
				{
					_state = "MOUNT";
					_stateChanged = true;
				};
			};
			case "ARRIVAL":
			{
				if (_stateChanged) then
				{
					diag_log format ["AI_fnc_landConvoy: entered ARRIVAL state"];
					{
						private _vehHandle = _x select 0;
						_vehHandle setConvoySeparation 10; //Make them stay a bit closer when they arrive
					} forEach (_armedVehArray + _unarmedVehArray);
					_stateChanged = false;
				};
				//From now, the only way to do something else is to set a new destination, then the general part of FSM will start running again
				if (_scriptObject getVariable "AI_destPosChanged") then
				{
					diag_log format ["AI_fnc_landConvoy: convoy has arrived but was assigned a new destination", _destPos];
					_state = "MOVE";
					_stateChanged = true;
				};
			};
		};
	};
};

//Return the script handle
_hScript

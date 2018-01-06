/*
Script for managine units in a convoy

_extraParams:
	[_armedVehGroups, _unarmedVehGroups, _destPos]
		_armedVehGroups - array of [_vehUnitData, _crewUnitData, _infGroupID] per every vehicle that can shoot with crew:
			_vehGroupID - _groupID of the vehicle group
			_infGroupID - the groupID of the infantry this vehicle is carrying, or -1 if it carries no inf. groups
		_unarmedVehGroups - the sama as _armedVehArray but for vehicles that can't shoot (trucks, ...)
		_destPos - the position of the destination
*/

#define DEBUG

params ["_scriptObject", "_extraParams"];

private _hScript = [_scriptObject, _extraParams] spawn
{
	//Read input parameters
	params ["_scriptObject", "_extraParams"];
	_extraParams params ["_armedVehGroups", "_unarmedVehGroups", "_destPos"];
	#ifdef DEBUG
		diag_log format ["AI_fnc_landConvoy.sqf: _armedVehGroups: %1, _unarmedVehGroups: %2", _armedVehGroups, _unarmedVehGroups];
	#endif
	
	//Read other things
	private _gar = _scriptObject getVariable ["AI_garrison", objNull];
	
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
		private	_vehUnitData = _groupUnits select 0;
		private _crewUnitData = _groupUnits - [_vehUnitData];
		private _infGroupID = _x select 1;
		_armedVehArray pushBack [_vehUnitData, _crewUnitData, _infGroupID];
		{ //forEach _groupUnits;
			[_gar, _x, _vehGroupID, false] call gar_fnc_joinGroup;
		} forEach _groupUnits;
	} forEach _armedVehGroups;
	{ // forEach _unarmedVehGroups
		private _groupUnits = ([_gar, _x select 0] call gar_fnc_getGroupUnits);
		private	_vehUnitData = _groupUnits select 0;
		private _crewUnitData = _groupUnits - [_vehUnitData];
		private _infGroupID = _x select 1;
		_unarmedVehArray pushBack [_vehUnitData, _crewUnitData, _infGroupID];
		{ //forEach _groupUnits;
			[_gar, _x, _vehGroupID, false] call gar_fnc_joinGroup;
		} forEach _groupUnits;
	} forEach _unarmedVehGroups;
	
	#ifdef DEBUG
		diag_log format ["AI_fnc_landConvoy.sqf: _armedVehArray: %1, _unarmedVehArray: %2", _armedVehArray, _unarmedVehArray];
	#endif
	
	//We need the power of the Finite State Machine!
	private _state = "MOUNT";
	private _stateChanged = true;
	while {true} do
	{
		sleep 2;
		switch (_state) do
		{
			case "MOUNT":
			{
				if (_stateChanged) then
				{
					diag_log format ["AI_fnc_landConvoy: entered MOUNT state"];
					_stateChanged = false;
				};
				//Order vehicle crew and infantry to get in	
				private _vehGroupHandle = [_gar, _vehGroupID] call gar_fnc_getGroupHandle;				
				private _infAndCrewHandles = [];
				{ //forEach _vehArray;
					private _vehUnitData = _x select 0;
					private _crewUnitData = _x select 1;
					private _infGroupID = _x select 2;
					private _vehHandle = [_gar, _vehUnitData] call gar_fnc_getUnitHandle;
					private _infUnitData = if(_infGroupID != -1) then {[_gar, _infGroupID] call gar_fnc_getGroupUnits;}
					else {[];};
					
					{
						private _crewHandle = [_gar, _x] call gar_fnc_getUnitHandle;
						_crewHandle doFollow (leader _vehGroupHandle);
						_infAndCrewHandles pushBack _crewHandle;
					} forEach _crewUnitData;
					{
						private _hInf = [_gar, _x] call gar_fnc_getUnitHandle;
						_infAndCrewHandles pushBack _hInf;
						_hInf assignAsCargo _vehHandle;
					} forEach _infUnitData;
				} forEach (_armedVehArray + _unarmedVehArray);				
				_infAndCrewHandles orderGetIn true;
				//Check if all the infantry has boarded their vehicles
				private _infAndCrewInVehHandles = _infAndCrewHandles select {!(vehicle _x isEqualTo _x)};
				diag_log format ["AI_fnc_landConvoy: waiting for units to get in: %1 / %2", count _infAndCrewInVehHandles, count _infAndCrewHandles];
				//Also check behaviour
				private _vehGroupHandle = [_gar, _vehGroupID] call gar_fnc_getGroupHandle;
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
				if (_stateChanged) then
				{
					diag_log format ["AI_fnc_landConvoy: entered MOVE state"];
					private _vehGroupHandle = [_gar, _vehGroupID] call gar_fnc_getGroupHandle;
					while {(count (waypoints _vehGroupHandle)) > 0} do
					{
						deleteWaypoint [_vehGroupHandle, ((waypoints _vehGroupHandle) select 0) select 1];
					};
					//Add new waypoint
					private _wp0 = _vehGroupHandle addWaypoint [_destPos, 100, 0, "Destination"];
					_wp0 setWaypointType "MOVE";
					_vehGroupHandle setCurrentWaypoint _wp0;
					_stateChanged = false;
				};
				private _vehGroupHandle = [_gar, _vehGroupID] call gar_fnc_getGroupHandle;
				private _beh = behaviour (leader _vehGroupHandle);
				#ifdef DEBUG
					diag_log format ["AI_fnc_landConvoy.sqf: behaviour: %1", _beh];
				#endif
				if (_beh == "COMBAT") then
				{
					_state = "DISMOUNT";
					_stateChanged = true;
				};
			};
			case "DISMOUNT":
			{
				if (_stateChanged) then
				{
					diag_log format ["AI_fnc_landConvoy: entered DISMOUNT state"];
					private _vehGroupHandle = [_gar, _vehGroupID] call gar_fnc_getGroupHandle;
					while {(count (waypoints _vehGroupHandle)) > 0} do
					{
						deleteWaypoint [_vehGroupHandle, ((waypoints _vehGroupHandle) select 0) select 1];
					};
					private _wp0 = _vehGroupHandle addWaypoint [getPos leader _vehGroupHandle, 15, 0, "Hold"];
					_wp0 setWaypointType "MOVE";
					_vehGroupHandle setCurrentWaypoint _wp0;
					_stateChanged = false;
				};
				//Order units to dismount
				private _infHandles = [];
				{ //forEach _unarmedVehArray;
					//Driver: stop and dismount
					private _crewUnitData = _x select 1;
					{
						private _driverHandle = [_gar, _x] call gar_fnc_getUnitHandle;
						doStop _driverHandle;
						[_driverHandle] orderGetIn false;
						_infHandles pushBack _driverHandle;
					} forEach _crewUnitData;
					//Infantry: dismount
					private _infGroupID = _x select 2;
					private _infGroupHandle = [_gar, _infGroupID] call gar_fnc_getGroupHandle;		
					(units _infGroupHandle) orderGetIn false;
					_infHandles append (units _infGroupHandle);
				} forEach _unarmedVehArray;	
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
					diag_log format ["AI_fnc_landConvoy: entered COMBAT state"];
					_stateChanged = false;
				};
				private _vehGroupHandle = [_gar, _vehGroupID] call gar_fnc_getGroupHandle;
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
		};
	};
};

//Return the script handle
_hScript
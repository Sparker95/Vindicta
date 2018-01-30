/*
call compile preprocessFileLineNumbers "AI\mission\initFunctions.sqf";
["SAD", WEST, 10, [[4100, 4600, 0]], "Attack mission"] call AI_fnc_mission_create;
_m = allMissions select 0;
_g = (alllocations select 1) call loc_fnc_getMainGarrison;
[_m, _g] call AI_fnc_mission_calculateEfficiency;
true spawn AI_fnc_mission_missionMonitor;
*/

/*
Mission types:
	SAD
		parameters:
			_target - Pos ARRAY or Location OBJECT
*/

#define DEBUG

AI_fnc_mission_create =
{
	/*
	Creates a new mission object
	*/
	params ["_type", "_side", "_requirements", "_extraParams", ["_name", "Noname mission"]];
	private _mo = groupLogic createUnit ["LOGIC", [10, 10, 10], [], 0, "NONE"]; //Create a logic object
	_mo setVariable ["AI_m_type", _type, false];
	_mo setVariable ["AI_m_state", "IDLE", false];
	_mo setVariable ["AI_m_params", _extraParams];
	_mo setVariable ["AI_m_name", _name, false];
	_mo setVariable ["AI_m_rGarrisons", [], false]; //Array with registered garrisons
	_mo setVariable ["AI_m_aGarrisons", [], false]; //Array with assigned garrisons
	_mo setVariable ["AI_m_requirements", _requirements, false]; //Requirements to register for this mission
	_mo setVariable ["AI_m_side", _side, false]; //Side of the mission
	allMissions pushBack _mo;
	//Return value
	_mo
};

AI_fnc_mission_getSide =
{
	params ["_mo"];
	_mo getVariable "AI_m_side"
};

AI_fnc_mission_getType =
{
	params ["_mo"];
	_mo getVariable "AI_m_type";
};

AI_fnc_mission_getName =
{
	params ["_mo"];
	_mo getVariable "AI_m_name";
};

AI_fnc_mission_delete =
{
	/*
	Deletes the missio object
	*/
	params ["_mo"];
	allMissions = allMissions - [_mo];
	if(isNull _mo) exitWith
	{
		diag_log "AI_fnc_mission_delete: error: mission is objNull!";
	};
	deleteVehicle _mo;
};

AI_fnc_mission_start =
{
	/*
	Starts the mission
	*/
	params ["_mo"];
	
	//Check which garrisons have registered for the mission
	private _rGarrisons = +(_mo getVariable "AI_m_rGarrisons");
	if(count _rGarrisons > 0) then //If there is someone able to do the mission
	{
		#ifdef DEBUG
		diag_log format ["AI_fnc_mission_start: starting mission: %1", _mo getVariable "AI_m_name"];
		#endif
		//Sort the registered garrison array in descending order
		_rGarrisons sort false;
		//Pick the most suitable garrison
		private _gar = _rGarrisons select 0 select 0;
		[_mo, _gar] call AI_fnc_mission_assignGarrison;
		//Set mission state
		_mo setVariable ["AI_m_state", "RUNNING"];
		//Unregister the garrison from all missions
		{
			[_x, _gar] call AI_fnc_mission_unregisterGarrison;
		} forEach allMissions;
		//Unregister all garrisons from this mission
		_mo setVariable ["AI_m_rGarrisons", [], false];
	}
	else //Do nothing
	{
		diag_log format ["mission.sqf: ERROR: no garrison registered for mission: %1", _mo getVariable "AI_m_name"];
	};
};

AI_fnc_mission_stop =
{
	/*
	Stops a mission
	*/
	params ["_mo"];
	//Find all garrisons currently running this mission
	private _gars = _mo getVariable "AI_m_aGarrisons";
	{
		_x call AI_fnc_mission_unassignGarrison;
	} forEach _gars;
	//Set mission state
	_mo setVariable ["AI_m_state", "IDLE", false];
};

AI_fnc_mission_assignGarrison =
{
	/*
	Assigns garrisons to the task.
	*/
	params ["_mo", "_gar"];
	
	//Initiate some variables
	private _rid = 0;
	private _rarray = [];
	private _mRequirements = _mo getVariable "AI_m_requirements"; //The amount of required soldiers
	
	//Create new garrison object
	private _garMission = [] call gar_fnc_createGarrison;
	gGarMission = _garMission;
	[_garMission, "Mission garrison"] call gar_fnc_setName;
	[_garMission, _gar call gar_fnc_getSide] call gar_fnc_setSide;
	[_garMission, _gar call gar_fnc_getLocation] call gar_fnc_setLocation;
	//Spawn the new garrison so that units that will join it will spawn as well
	_garMission call gar_fnc_spawnGarrison;
	
	//Create a new group for infantry
	_rid = [_gar, G_GT_idle, _rarray] call gar_fnc_addNewEmptyGroup;
	waitUntil {[_gar, _rid] call gar_fnc_requestDone};
	private _infGroupID = _rarray select 0;
	
	//Allocate infantry units
	private _infGroupIDs = [];
	_infGroupIDs append ([_gar, G_GT_idle] call gar_fnc_findGroups);
	_infGroupIDs append ([_gar, G_GT_patrol] call gar_fnc_findGroups);
	
	//Find infantry units
	private _allInfUnits = [];
	{
		_allInfUnits append ([_gar, _x] call gar_fnc_getGroupAliveUnits);
	} forEach _infGroupIDs;
	
	//Move infantry units into the new group
	private _j = _mRequirements;
	while {(count _allInfUnits) > 0 && _j > 0} do
	{
		private _unitData = _allInfUnits select ((count _allInfUnits) - 1);
		_rid = [_gar, _unitData, _infGroupID, true] call gar_fnc_joinGroup;
		_allInfUnits = _allInfUnits - [_unitData];
		_j = _j - 1;
	};
	waitUntil {[_gar, _rid] call gar_fnc_requestDone};
	
	//Move the infantry group into the new garrison
	_rid = [_gar, _garMission, _infGroupID, []] call gar_fnc_moveGroup;
	
	//Allocate transport vehicles for the infantry
	private _allVehUnits = [_gar, T_VEH, -1] call gar_fnc_findUnits;
	private _cargoCapacity = 0;
	private _i = 0;
	private _nVehicles = count _allVehUnits;
	while {_cargoCapacity < _mRequirements && _i < _nVehicles} do
	{
		private _unitData = _allVehUnits select _i;
		private _classname = [_gar, _unitData] call gar_fnc_getUnitClassname;
		private _fullCrew = _classname call misc_fnc_getFullCrew;
		private _cc  = _classname call misc_fnc_getCargoInfantryCapacity; //Cargo capacity of this vehicle
		if (_fullCrew select 0 == 1 && _cc > 0) then //If vehicle has a driver and can carry cargo
		{
			//Check if vehicle is in group or not
			private _vehGRoupID = [_gar, _unitData] call gar_fnc_getUnitGroupID;
			if (_vehGroupID == -1) then
			{
				//If vehicle doesn't have a group, just move it to the other garrison
				_rid = [_gar, _garMission, _unitData, -1] call gar_fnc_moveUnit;
			}
			else
			{
				//If vehicle is in group, move the whole group to the other garrison
				_rid = [_gar, _garMission, _vehGroupID] call gar_fnc_moveGroup;
			};
		};
		_cargoCapacity = _cargoCapacity + _cc;
		_i = _i + 1;
	};
	waitUntil {[_gar, _rid] call gar_fnc_requestDone};
	
	//Allocate crew for the vehicles
	[_garMission, [_gar, _garMission]] call AI_fnc_formVehicleGroup;
	
	//Restart AI scripts of the location (if garrison was assigned from a location)
	private _loc = _gar call gar_fnc_getLocation;
	if(!isNull _loc) then
	{
		_loc call loc_fnc_restartEnemiesScript;
		_loc call loc_fnc_restartAlertStateScript;
	};
	
	#ifdef DEBUG
	diag_log format ["AI_fnc_mission_assignGarrison: garrison %1 has been assigned for mission: %2",
		_garMission call gar_fnc_getName, _mo getVariable "AI_m_name"];
	#endif
	
	//Store the garrison object into array
	private _aGarrisons = _mo getVariable "AI_m_aGarrisons"; //Assigned garrisons
	_aGarrisons pushBack _garMission;
	
	//Start a mission thread for this garrison
	private _hScript = _garMission call gar_fnc_getMissionThreadHandle;
	if (scriptDone _hScript) then //If it's scriptNull OR if the previous script has been terminated
	{
		_hScript = _garMission spawn AI_fnc_mission_garrisonThread;
		[_gar, _hScript] call gar_fnc_setMissionThreadHandle;
	};
	[_garMission, _mo] call gar_fnc_setAssignedMission;
};

AI_fnc_mission_unassignGarrison =
{
	/*
	Unassigns garrisons from the task.
	*/
	params ["_mo", "_gar"];
	private _gm = _gar call gar_fnc_getAssignedMission;
	if(_gm isEqualTo _mo) then
	{
		//_gar call gar_fnc_unassignMission;
		[_gm, objNull] call gar_fnc_setAssignedMission;
		private _aGarrisons = _mo getVariable "AI_m_aGarrisons"; //Assigned garrisons
		_aGarrisons  = _aGarrisons - [_gar];
		_mo setVariable ["AI_m_aGarrisons", _aGarrisons, false];
	};
};

AI_fnc_mission_getAssignedGarrisons =
{
	params ["_mo"];
	_mo getVariable "AI_m_aGarrisons";
};

AI_fnc_mission_registerGarrison =
{
	/*
	Registers a garrison to a mission
	*/
	params ["_mo", "_gar", "_efficiency"];
	private _rGars = _mo getVariable "AI_m_rGarrisons";
	_rGars pushBack [_gar, _efficiency];
	
	#ifdef DEBUG
	diag_log format ["AI_fnc_mission_registerGarrison: garrison %1 has been registered for mission: %2, efficiency: %3",
		_gar call gar_fnc_getName, _mo getVariable "AI_m_name", _efficiency];
	#endif
};

AI_fnc_mission_getRegisteredGarrisons =
{
	/*
	Returns an array of all garrisons assigned to this mission, without efficiency.
	*/
	params ["_mo"];
	private _g = _mo getVariable "AI_m_rGarrisons";
	private _return = [];
	{
		_return pushBack (_x select 0); //Structure is: [_garrison, _efficiency]
	} forEach _g;
	_return
};

AI_fnc_mission_unregisterGarrison =
{
	/*
	Unregisters a garrison from a mission
	*/
	params ["_mo", "_gar"];
	private _rGars = _mo getVariable "AI_m_rGarrisons";
	private _rGarsFound = _rGars select {_x select 0 isEqualTo _gar};
	if(!(_rGarsFound isEqualTo [])) then //If some registered garrison has been found
	{
		_rGars = _rGars - _rGarsFound;
	};
};
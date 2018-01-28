#define DEBUG

AI_fnc_mission_create =
{
	/*
	Creates a new mission object
	*/
	params ["_type", "_pos", "_side", "_requirements", ["_name", "Noname mission"]];
	private _mo = groupLogic createUnit ["LOGIC", _pos, [], 0, "NONE"]; //Create a logic object
	_mo setVariable ["AI_m_type", _type, false];
	_mo setVariable ["AI_m_state", "IDLE", false];
	_mo setVariable ["AI_m_name", _name, false];
	_mo setVariable ["AI_m_rGarrisons", [], false]; //Array with registered garrisons
	_mo setVariable ["AI_m_aGarrisons", [], false]; //Array with assigned garrisons
	_mo setVariable ["AI_m_requirements", [], false]; //Requirements to register for this mission
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
	private _gRegistered = +(_mo getVariable "AI_m_gRegistered");
	if(count _gRegistered > 0) then //If there is someone able to do the mission
	{
		//Sort the registered garrison array in descending order
		_gRegistered sort false;
		//Pick the most suitable garrison
		private _gar = _gRegistered select 0;
		[_mo, _gar] call AI_fnc_mission_assignGarrison;
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
	while {(count _allInfUnits) > 0 && _j > -1} do
	{
		private _unitData = _allInfUnits select ((count _allInfUnits) - 1);
		_rid = [_gar, _unitData, _infGroupID, true] call gar_fnc_joinGroup;
		_allInfUnits = _allInfUnits - [_unitData];
		_j = _j - 1;
	};
	waitUntil {[_gar, _rid] call gar_fnc_requestDone};
	
	//Move the infantry group into the new garrison
	_rid = [_gar, _garMission, _infGroupID] call gar_fnc_moveGroup;
	
	//Allocate transport vehicles for the infantry
	private _allVehUnits = [_gar, T_INF, -1] call gar_fnc_findUnits;
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
				_rid = [_gar, _garMission, _unitData] call gar_fnc_moveUnit;
			}
			else
			{
				//If vehicle is in group, move the whole group to the other garrison
				_rid = [_gar, _garMission, _vehGroupID] call gar_fnc_moveGroup;
			};
		};
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
	
	private _gAssigned = _mo getVariable "AI_m_gAssigned";
	_gAssigned pushBack _garMission;
	[_garMission, _mo] call gar_fnc_assignMission;
};

AI_fnc_mission_unassignGarrison =
{
	/*
	Unassigns garrisons fromw the task.
	*/
};

AI_fnc_mission_registerGarrison =
{
	/*
	Registers a garrison to a mission
	*/
	params ["_mo", "_gar", "_efficiency"];
	private _rGars = _mo getVariable "AI_m_rGarrisons";
	_rGars pushBack [_gar, _efficiency];
};

AI_fnc_mission_getRegistered_garrisons =
{
	params ["_mo"];
	_mo getVariable "AI_m_gRegistered"
};

AI_fnc_mission_unregisterGarrison =
{
	/*
	Unregisters a garrison from a mission
	*/
	params ["_mo", "_gar"];
	private _rGars = _mo getVariable "AI_m_rGarrisons";
	private _rGarsFound = _rGars select {_x select 0 isEqualTo _gar};
	if(!_rGarsFound isEqualTo []) then //If some registered garrison has been found
	{
		_rGars = _rGars - _rGarsFound;
	};
};
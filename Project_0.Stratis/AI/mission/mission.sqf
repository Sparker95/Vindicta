/*
call compile preprocessFileLineNumbers "AI\mission\initFunctions.sqf"; 
["SAD", WEST, [[0, 0, 3, 0, 0, 0, 0, 0], [[], 0, 0, [objNull], [objNull]]], [[4100, 4600, 0], 300], "Attack mission"] call AI_fnc_mission_create;
*/

/*
Mission types:
	SAD
		requirements: [_efficiency]
			_efficiency - the efficiency vector required to perform the task
		parameters: [_target, _searchRadius]
			_target - Pos ARRAY or Location OBJECT
*/

#define DEBUG
#define DEBUG_MARKERS

AI_fnc_mission_create =
{
	/*
	Creates a new mission object
	*/
	params ["_type", "_side", "_requirements", "_extraParams", ["_name", "Noname mission"]];
	private _mo = "Sign_Arrow_Large_Pink_F" createVehicle [10, 10, 10];
	hideObjectGlobal _mo;
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
	_mo getVariable "AI_m_type"
};

AI_fnc_mission_getRequirements =
{
	params ["_mo"];
	_mo getVariable "AI_m_requirements"
};

AI_fnc_mission_getName =
{
	params ["_mo"];
	_mo getVariable "AI_m_name"
};

AI_fnc_mission_getState =
{
	params ["_mo"];
	_mo getVariable "AI_m_state"
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
	//Stop the mission
	_mo call AI_fnc_mission_stop;
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
		private _gar = _rGarrisons select 0 select 1;
		private _extraParams = _rGarrisons select 0 select 2;
		[_mo, _gar, _extraParams] call AI_fnc_mission_assignGarrison;
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
	if( isNull _mo) exitWith {};
	//Find all garrisons currently running this mission
	private _gars = _mo getVariable "AI_m_aGarrisons";
	{
		[_mo, _x] call AI_fnc_mission_unassignGarrison;
	} forEach _gars;
	//Set mission state
	_mo setVariable ["AI_m_state", "IDLE", false];
};

AI_fnc_mission_unassignGarrison =
{
	/*
	Unassigns garrison from the mission.
	*/
	params ["_mo", "_gar"];
	private _mission = _gar call gar_fnc_getAssignedMission;
	if(_mission isEqualTo _mo) then
	{
		//_gar call gar_fnc_unassignMission;
		[_gar, objNull] call gar_fnc_setAssignedMission;
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
	params ["_mo", "_gar", "_efficiency", "_extraParams"];
	private _rGars = _mo getVariable "AI_m_rGarrisons";
	_rGars pushBack [_efficiency, _gar, _extraParams];
	
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

AI_fnc_mission_unregisterAllGarrisons = {
	/*
	Accepts an array of missions or a single mission and resets its registered garrisons array.
	*/
	private _missions = _this;
	
	if (_missions isEqualType objNull) then {
		_missions = [_missions];
	};
	
	for "_i" from 0 to ((count _missions) - 1) do {
		private _mo = _missions select _i;
		_mo setVariable ["AI_m_rGarrisons", [], false]
	};
};
/*
This function allocates units from garrison to perform a mission into another garrison.
*/

#define DEBUG

params ["_mo", "_gar", "_extraParams"];

//Initiate some variables
private _rid = 0;
private _rarray = [];
private _mRequirements = _mo getVariable "AI_m_requirements"; //The amount of required soldiers
private _mType = _mo getVariable "AI_m_type";

switch (_mType) do
{
	case "SAD": {
		_mRequirements params ["_effReq"];
		_extraParams params ["_unitsPlanned"];
		
		//Create new garrison object
		private _garMission = [] call gar_fnc_createGarrison;
		gGarMission = _garMission;
		[_garMission, "Mission garrison"] call gar_fnc_setName;
		[_garMission, _gar call gar_fnc_getSide] call gar_fnc_setSide;
		[_garMission, _gar call gar_fnc_getLocation] call gar_fnc_setLocation;
		//Spawn the new garrison so that units that will join it will spawn as well
		_garMission call gar_fnc_spawnGarrison;
		
		//Allocate infantry units
		private _unitsPlannedInf = _unitsPlanned select {_x select 0 == T_INF};
		
		//Move infantry units into the new group
		if (count _unitsPlannedInf > 0) then {
			//Create a new group for infantry
			_rid = [_gar, G_GT_idle, _rarray] call gar_fnc_addNewEmptyGroup;
			waitUntil {[_gar, _rid] call gar_fnc_requestDone};
			private _infGroupID = _rarray select 0;
		
			for "_i" from 0 to ((count _unitsPlannedInf) - 1) do {
				private _unitData = _unitsPlannedInf select _i;
				_rid = [_gar, _unitData, _infGroupID, true] call gar_fnc_joinGroup;
			};
			
			//Move the infantry group into the new garrison
			_rid = [_gar, _garMission, _infGroupID, []] call gar_fnc_moveGroup;
			waitUntil {[_gar, _rid] call gar_fnc_requestDone};
		};
		
		//Allocate vehicles
		private _unitsPlannedVeh = _unitsPlanned select {_x select 0 == T_VEH};
		
		if (count _unitsPlannedVeh > 0) then {
			for "_i" from 0 to ((count _unitsPlannedVeh) - 1) do {
				private _unitData = _unitsPlannedVeh select _i;
				private _groupID = [_gar, _unitData] call gar_fnc_getUnitGroupID;
				//Vehicles with group are moved with their group
				if (_groupID != -1) then {
					_rid = [_gar, _garMission, _groupID, []] call gar_fnc_moveGroup;
				} else { //Vehicles without group are moved without a group
					_rid = [_gar, _garMission, _unitData, -1, []] call gar_fnc_moveUnit;
				};
			};
			waitUntil {[_gar, _rid] call gar_fnc_requestDone};
			
			//Allocate crew for the vehicles, 
			[_garMission, [_gar, _garMission]] call AI_fnc_formVehicleGroup;
		};
		
		//Restart AI scripts of the location (if garrison was assigned from a location)
		private _loc = _gar call gar_fnc_getLocation;
		if(!isNull _loc) then
		{
			_loc call loc_fnc_restartEnemiesScript;
			_loc call loc_fnc_restartAlertStateScript;
		};
		//Start enemyMonitor script for the new garrison
		_oEnemiesScript = [[_garMission], "AI_fnc_manageSpottedEnemies", []]
								call AI_fnc_startMediumLevelScript;
		_oEnemiesScript call sense_fnc_enemyMonitor_addScript;
		//Set garrison's location		
		//[_garMission, objNull] call gar_fnc_setLocation;
		
		#ifdef DEBUG
		diag_log format ["<AI_MISSION> INFO: AI_fnc_mission_assignGarrison: garrison %1 has been assigned for mission: %2",
			_garMission call gar_fnc_getName, _mo getVariable "AI_m_name"];
		#endif
		
		//Store the garrison object into array
		private _aGarrisons = _mo getVariable "AI_m_aGarrisons"; //Assigned garrisons
		_aGarrisons pushBack _garMission;
		
		//Set garrison's assigned mission
		[_garMission, _mo] call gar_fnc_setAssignedMission;
		
		//Start a mission thread for this garrison
		private _so = _garMission call gar_fnc_getMissionScriptObject;
		if (isNull _so) then //If the garrison doesn't have a mission thread yet
		{
			_so = ["AI_fnc_mission_garrisonThread", [_garMission]] call scriptObject_fnc_create;
			[_garMission, _so] call gar_fnc_setMissionScriptObject;
			_so call scriptObject_fnc_start;
		};
	};
};
/*
This function allocates units from garrison to perform a mission into another garrison.
*/

#define DEBUG

params ["_mo", "_gar"];

//Initiate some variables
private _rid = 0;
private _rarray = [];
private _mRequirements = _mo getVariable "AI_m_requirements"; //The amount of required soldiers
private _mType = _mo getVariable "AI_m_type";

switch (_mType) do
{
	case "SAD": {
		_mRequirements params ["_effReq"];
		
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
		private _nInf = _effReq select T_EFF_soft; //Test
		private _j = _nInf;
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
		//_nInf = 10; //Test
		while {_cargoCapacity < _nInf && _i < _nVehicles} do
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
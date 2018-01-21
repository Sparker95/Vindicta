/*
This function does following:
Takes all vehicles and their crew from _garTransport and combines them into a single group.
Tries to find all the required crew for the vehicles.
If there are more crew units in the vehicle group than needed, they will be moved to a different group.

As a result, in case of success, there should be a a single group with vehicles and their crew capable of moving and fighting. 

_garsDrivers will supply drivers for vehicles if they are not assigned yet.

Parameters:
_garsCrew - array of garrisons which can donate crew for vehicles, or a single garrison. It can also include _garTransport.

Return value:
	_nCrewToAdd:
		0 - there is a proper amount of crew in the _garTransport
		>0 (positive) - still need to find this amount of crew units
*/

#define DEBUG

params ["_garTransport", "_garsCrew"];

if (_garsCrew isEqualType objNull) then
{
	_garsCrew = [_garsCrew];
};

//Common variables
private _rid = 0;
private _rarray = [];

//Make an array with available drivers, for the case if drivers for some vehicles won't be assigned
private _freeCrewArray = []; //Array of [_gar, _unitData]
{
	private _gar = _x;
	//Find groups that can donate units: idle and patrol groups
	private _groups = [_gar, G_GT_idle] call gar_fnc_findGroups;
	_groups append ([_gar, G_GT_patrol] call gar_fnc_findGroups);
	private _groupUnits = [];
	{ //Get units of these groups
		_groupUnits append ([_gar, _x] call gar_fnc_getGroupUnits);
	} forEach _groups;
	{ //Add all the units to the array
		_freeCrewArray pushBack [_gar, _x];
	} forEach _groupUnits;
} forEach _garsCrew;


//==== Compose vehicles into one group ====
//Make a list of groups of all vehicles
private _allVehicleUnits = [_garTransport, T_VEH, -1] call gar_fnc_findUnits; //Find all vehicles
private _allVehicleGroupIDs = [];
{
	private _vehicleGroupID = [_garTransport, _x] call gar_fnc_getUnitGroupID;
	_allVehicleGroupIDs pushBackUnique _vehicleGroupID;
} forEach _allVehicleUnits;


#ifdef DEBUG
diag_log format ["fn_formVehicleGroup.sqf: _allVehicleGroupIDs: %1", _allVehicleGroupIDs];
#endif

//Find or create a group for vehicles
private _vehGroupID = -1;
//If there is a proper vehicle group already, use it
if (({_x != -1} count _allVehicleGroupIDs) > 0) then
{
	_vehGroupID = (_allVehicleGroupIDs select {_x != -1}) select 0;
}
else
{
	//Otherwise create a new group
	private _rid = [_garTransport, G_GT_veh_non_static, _rarray] call gar_fnc_addNewEmptyGroup;
	waitUntil {sleep 0.001; [_garTransport, _rid] call gar_fnc_requestDone};
	_vehGroupID = _rarray select 0;
	#ifdef DEBUG
	diag_log format ["fn_formVehicleGroup.sqf: no vehicle groups found, created a new one: %1", _vehGroupID];
	#endif
};

//Compose all vehicles that have a group into one group
private _existingGroupIDs = _allVehicleGroupIDs select {_x != -1};
#ifdef DEBUG
diag_log format ["fn_formVehicleGroup.sqf: _existingVehicleGroupIDs: %1", _existingGroupIDs];
#endif
if (count _existingGroupIDs > 1) then
{
	for "_i" from 0 to ((count _existingGroupIDs) - 1) do
	{
		private _groupID = _existingGroupIDs select _i;
		if (_groupID != _vehGroupID) then
		{
			#ifdef DEBUG
			diag_log format ["fn_formVehicleGroup.sqf: joining group %1 into group %2", _groupID, _vehGroupID];
			#endif
			_rid = [_garTransport, [_garTransport, _groupID] call gar_fnc_getGroupUnits, _vehGroupID, false] call gar_fnc_joinGroup;
		};
	};
	waitUntil {[_garTransport, _rid] call gar_fnc_requestDone};
};

//Move vehicles without a group into the vehicle group
if(-1 in _allVehicleGroupIDs) then
{
	for "_i" from 0 to ((count _allVehicleUnits) - 1) do
	{
		private _veh = _allVehicleUnits select _i;
		private _curGroupID = [_garTransport, _veh] call gar_fnc_getUnitGroupID;
		//Check if the vehicle is ungrouped
		if(_curGroupID == -1) then
		{
			#ifdef DEBUG
			diag_log format ["fn_formVehicleGroup.sqf: moving vehicle %1 into group %2", _veh, _vehGroupID];
			#endif
			_rid = [_garTransport, _veh, _vehGroupID, false] call gar_fnc_joinGroup;
		};
	};
	waitUntil {[_garTransport, _rid] call gar_fnc_requestDone};
};

//==== Find crew for vehicles ====
//Calculate how many crew units are needed
private _nCrewNeeded = 0;
for "_i" from 0 to ((count _allVehicleUnits) - 1) do
{
	//Join group
	private _veh = _allVehicleUnits select _i;
	//Calculate the amount of neede crew
	private _className = [_garTransport, _veh] call gar_fnc_getUnitClassName;
	private _fullCrew = _className call misc_fnc_getFullCrew;
	_nCrewNeeded = _nCrewNeeded + ( (_fullCrew select 0) + (count (_fullCrew select 1)) + (count (_fullCrew select 2)) ); //# of drivers, copilots and turrets
};

//Number of crew units currently in the vehicle group
private _nCrewCurrent = {_x select 0 == T_INF} count ([_garTransport, _vehGroupID] call gar_fnc_getGroupAliveUnits);
//Number of crew units that need to be added (or removed, if negative)
private _nCrewToAdd = _nCrewNeeded - _nCrewCurrent;

#ifdef DEBUG
diag_log format ["fn_formVehicleGroup.sqf: _nCrewNeeded: %1, _nCrewCurrent: %2, _nCrewToAdd: %3", _nCrewNeeded, _nCrewCurrent, _nCrewToAdd];
#endif

if(_nCrewToAdd != 0) then
{
	if (_nCrewToAdd > 0) then
	{
		//Add new units to the vehicle group
		private _index = (count _freeCrewArray) - 1;
		while {(_nCrewToAdd > 0) && (_index > -1)} do
		{
			private _gar = _freeCrewArray select _index select 0;
			private _unitData = _freeCrewArray select _index select 1;
			if(_gar isEqualTo _garTransport) then //If the available unit is in garTransport, make it join the group
			{ //Join group
				[_garTransport, _unitData, _vehGroupID, true] call gar_fnc_joinGroup;
			}
			else
			{ //Move unit into _garTransport
				private _rid = [_gar, _garTransport, _unitData, _vehGroupID] call gar_fnc_moveUnit;
				//Must wait until the unit has been transfered to _garTransport before assigning vehicle roles
				waitUntil {[_gar, _rid] call gar_fnc_requestDone};
			};
			#ifdef DEBUG
			diag_log "fn_formVehicleGroup.sqf: added a new crew unit to the vehicle group";
			#endif
			_index = _index - 1;
			_nCrewToAdd = _nCrewToAdd - 1;
		};
	}
	else
	{
		//Negative _nCrewToAdd means that there are extra (-_nCrewToAdd) crew units in the group
		//Remove the not needed crew units from the vehicle group
		//Find a group which will accept units
		private _infGroupIDs = [_garTransport, G_GT_idle] call gar_fnc_findGroups;
		_infGroupIDs append ([_garTransport, G_GT_patrol] call gar_fnc_findGroups);
		//If there are no such groups, create one
		private _infGroupID = -1;
		if (count _infGroupIDs == 0) then
		{
			_rid = [_garTransport, G_GT_idle, _rarray] call gar_fnc_addNewEmptyGroup;
			waitUntil {[_garTransport, _rid] call gar_fnc_requestDone};
			_infGroupID = _rarray select 0;
		}
		else
		{ //If such a group exists, pick the first one
			_infGroupID = _infGroupIDs select 0;
		};
		//Find all the crew units in the vehicle group
		private _crewUnits = ([_garTransport, _vehGroupID] call gar_fnc_getGroupUnits) select {_x select 0 == T_INF};
		//Move the crew units into the infantry group we have just created
		private _i = (count _crewUnits) - 1;
		while {_nCrewToAdd < 0} do
		{
			#ifdef DEBUG
			diag_log "fn_formVehicleGroup.sqf: removed a crew unit from the vehicle group";
			#endif
			[_garTransport, _crewUnits select _i, _infGroupID, false] call gar_fnc_joinGroup;
			_i = _i - 1;
			_nCrewToAdd = _nCrewToAdd + 1;
		};
	};
};

//Assign vehicle roles
private _rid = [_garTransport, _vehGroupID, true, true, false] call gar_fnc_assignVehicleRoles;
waitUntil {[_garTransport, _rid] call gar_fnc_requestDone};

//Return value
_nCrewToAdd
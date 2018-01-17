/*
Takes all vehicles and their crew from _garTransport and combines them into a single group.
_garsDrivers will supply drivers for vehicles if they are not assigned yet.

Parameters:
_garsCrew - array of garrisons which can donate crew for vehicles, or a single garrison

//TODO: add as a parameter a garrison which will receive vehicles to dump to if the vehicle doesn't have a driver.
*/

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


//Move all the vehicles into one group if needed
private _allVehicleUnits = [_garTransport, T_VEH, -1] call gar_fnc_findUnits; //Find all vehicles
private _allVehicleGroupIDs = [];
{
	private _vehicleGroupID = [_garTransport, _x] call gar_fnc_getUnitGroupID;
	_allVehicleGroupIDs pushBackUnique _vehicleGroupID;
} forEach _allVehicleUnits;

//If all the vehicles are ungrouped OR there are multiple vehicle groups
if ((count _allVehicleGroupIDs == 0 && (_allVehicleGroupIDs select 0 == -1)) || (count _allVehicleGroupIDs) > 1) then
{	
	private _vehGroupID = -1;
	//If there is a proper vehicle group already, use it
	if(count _allVehicleGroupIDs > 1) then
	{
		_vehGroupID = (_allVehicleGroupIDs select {_x != -1}) select 0;
	}
	else
	{
		//Otherwise create a new group
		private _rid = [_garTransport, G_GT_veh_non_static, _rarray] call gar_fnc_addNewEmptyGroup;
		waitUntil {sleep 0.01; [_garTransport, _rid] call gar_fnc_requestDone};
		_vehGroupID = _rarray select 0;
	};
	
	//Compose all vehicles that have a group into one group
	private _existingGroupIDs = _allVehicleGroupIDs select {_x != -1};
	if (count _existingGroupIDs > 1) then
	{
		for "_i" from 0 to ((count _existingGroupIDs) - 1) do
		{
			private _groupID = _existingGroupIDs select _i;
			_rid = [_garTransport, [_garTransport, _groupID] call gar_fnc_getGroupUnits, _vehGroupID, false] call gar_fnc_joinGroup;
			waitUntil {sleep 0.01; [_garTransport, _rid] call gar_fnc_requestDone};
		};
	};
	
	//Compose all ungrouped vehicles into the same group
	//Also calculate how many crew is needed
	private _nCrewNeeded = 0;
	for "_i" from 0 to ((count _allVehicleUnits) - 1) do
	{
		//Join group
		private _veh = _allVehicleUnits select _i;
		_rid = [_garTransport, _veh, _vehGroupID, false] call gar_fnc_joinGroup;
		//Calculate the amount of neede crew
		private _className = [_garTransport, _veh] call gar_fnc_getUnitClassName;
		private _fullCrew = _className call misc_fnc_getFullCrew;
		_nCrewNeeded = _nCrewNeeded + ( (_fullCrew select 0) + (count (_fullCrew select 1)) + (count (_fullCrew select 2)) ); //# of drivers, copilots and turrets
	};
	
	private _nCrewCurrent = {_x select 0 == T_INF} count ([_garTransport, _vehGroupID] call gar_fnc_getGroupUnits);
	private _nCrewToAdd = _nCrewNeeded - _nCrewCurrent;
	
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
					[_garTransport, _unitData, _vehGroupID] call gar_fnc_joinGroup;
				}
				else
				{ //Move unit into _garTransport
					private _rid = [_gar, _garTransport, _unitData, _vehGroupID] call gar_fnc_moveUnit;
					waitUntil {sleep 0.01; [_gar, _rid] call gar_fnc_requestDone}; //need to wait until the unit has been transfered to _garTransport before assigning vehicle roles
				};
				_index = _index - 1;
				_nCrewToAdd = _nCrewToAdd - 1;
			};
		}
		else
		{
			//Remove units from the vehicle group
		};
	};
	[_garTransport, _vehGroupID, true, true, false] call gar_fnc_assignVehicleRoles;
};

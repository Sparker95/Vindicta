/*
Just my attempt to make a convoy to see how modules work!
This should be redone!
*/

params ["_locFrom", "_locTo"];

//Get main garrison of the initial location
private _garFrom = _locFrom call loc_fnc_getMainGarrison;

//Find needed units
//Find trucks
private _allTrucks = [_garFrom, T_VEH, T_VEH_truck_inf] call gar_fnc_findUnits;
diag_log format ["convoy.sqf: found trucks for convoy: %1", _allTrucks];

//Find armed vehicles
private _allArmedVeh = [_garFrom, T_VEH, T_VEH_MRAP_unarmed] call gar_fnc_findUnits;
_allArmedVeh append ([_garFrom, T_VEH, T_VEH_MRAP_HMG] call gar_fnc_findUnits);
_allArmedVeh append ([_garFrom, T_VEH, T_VEH_MRAP_GMG] call gar_fnc_findUnits);
_allArmedVeh append ([_garFrom, T_VEH, T_VEH_APC] call gar_fnc_findUnits);
_allArmedVeh append ([_garFrom, T_VEH, T_VEH_IFV] call gar_fnc_findUnits);
diag_log format ["convoy.sqf: found armed vehicles for convoy: %1", _allArmedVeh];

//Find groups with troops
private _allInfGroupIDs = [_garFrom, G_GT_idle] call gar_fnc_findGroups;
diag_log format ["convoy.sqf: found infantry groups for convoy: %1", _allInfGroupIDs];

//Create new garrison object for the convoy
private _garConvoy = [] call gar_fnc_createGarrison;
[_garConvoy, "Convoy garrison"] call gar_fnc_setName;
[_garConvoy, _garFrom call gar_fnc_getSide] call gar_fnc_setSide;
[_garConvoy, _locFrom] call gar_fnc_setLocation;
//Spawn the new garrison so that units that will join it will spawn as well
_garConvoy call gar_fnc_spawnGarrison;

//Make a new group for the vehicles and their crew
private _truck = _allTrucks select 0;
private _rarray = []; //Return array
private _rid = [_garFrom, G_GT_veh_non_static, _rarray] call gar_fnc_addNewEmptyGroup;
waitUntil {sleep 0.1; [_garFrom, _rid] call gar_fnc_requestDone};
private _vehGroupID = _rarray select 0;
diag_log format ["Truck's group ID: %1", _vehGroupID];

//Find a driver for the truck
private _infGroupID = _allInfGroupIDs select 0;
private _infGroupUnits = [_garFrom, _infGroupID] call gar_fnc_getGroupUnits;
private _truckDriver = _infGroupUnits select ((count _infGroupUnits) - 1);

//Move the truck and its driver to new group
[_garFrom, _truck, _vehGroupID, false] call gar_fnc_joinGroup;
_rid = [_garFrom, _truckDriver, _vehGroupID, true] call gar_fnc_joinGroup;
waitUntil {sleep 0.1; [_garFrom, _rid] call gar_fnc_requestDone};
diag_log format ["New group structure after moving unit: %1", [_garFrom, _vehGroupID] call gar_fnc_getGroup];

//Move the truck and its driver to new garrison
_rid = [_garFrom, _garConvoy, _vehGroupID, _rarray] call gar_fnc_moveGroup;
waitUntil {sleep 0.1; [_garFrom, _rid] call gar_fnc_requestDone};
_vehGroupID = _rarray select 0;
diag_log format ["Truck's group ID: %1", _vehGroupID];

//Move armed vehicles to the new garrison
private _armedVeh = [_allArmedVeh select 0];
if(count _allArmedVeh > 1) then
{
	_armedVeh pushBack (_allArmedVeh select 1);
};
diag_log format ["convoy.sqf: armed vehicles: %1", _armedVeh];
private _armedVehGroupID = []; //Group IDs of the vehicles in the new garrison
private _armedVehInitialGroups = []; //Composition of vehicle groups before they were merged for the convoy
{
	private _gid = [_garFrom, _x] call gar_fnc_getUnitGroupID;
	_rid = [_garFrom, _garConvoy, _gid, _rarray] call gar_fnc_moveGroup;
	waitUntil {sleep 0.1; [_garFrom, _rid] call gar_fnc_requestDone};
	_armedVehGroupID pushBack (_rarray select 0);
	_armedVehInitialGroups pushBack [[_garConvoy, _rarray select 0] call gar_fnc_getGroupUnits];
} forEach _armedVeh;

//Move the infantry group into new garrison
_rid = [_garFrom, _garConvoy, _infGroupID, _rarray] call gar_fnc_moveGroup;
waitUntil {sleep 0.1; [_garFrom, _rid] call gar_fnc_requestDone};
_infGroupID = _rarray select 0;

//After repartitioning of garrisons, the location's AI scripts need to be restarted
_locFrom call loc_fnc_restartAlertStateScript;
_locFrom call loc_fnc_restartEnemiesScript;

//Merge all vehicles and their crews in the new garrison into one group
{
	{
		_rid = [_garConvoy, _x, _vehGroupID, false] call gar_fnc_joinGroup;
		waitUntil {sleep 0.1; [_garFrom, _rid] call gar_fnc_requestDone};
	} forEach ([_garConvoy, _x] call gar_fnc_getGroupUnits);
} forEach _armedVehGroupID;

//Order get in!
private _infGroupUnits = [_garConvoy, _infGroupID] call gar_fnc_getGroupUnits;
private _infGroupHandle = [_garConvoy, _infGroupID] call gar_fnc_getGroupHandle;
private _vehGroupUnits = [_garConvoy, _vehGroupID] call gar_fnc_getGroupUnits;
private _vehGroupHandle = [_garConvoy, _vehGroupID] call gar_fnc_getGroupHandle;
private _truckHandle = [_garConvoy, _vehGroupUnits select 0] call gar_fnc_getUnitHandle;
//private _truckDriverHandle = [_garConvoy, _vehGroupUnits select 1] call gar_fnc_getUnitHandle;
//_truckDriverHandle assignAsDriver _truckHandle;
(units _vehGroupHandle) orderGetIn true;
(units _vehGroupHandle) doFollow (leader _vehGroupHandle);
{
	_x assignAsCargo _truckHandle;
} forEach (units _infGroupHandle);
(units _infGroupHandle) orderGetIn true;
//[_truckDriverHandle] joinSilent (group _truckDriverHandle);
//_truckDriverHandle doFollow _truckDriverHandle;
//_truckDriverHandle doMove [3400, 3600, 0];
diag_log format ["Waiting until all units board their vehicles"];

waitUntil
{
	sleep 2;
	private _crewHandles = units _vehGroupHandle;
	private _infHandles = units _infGroupHandle;
	_crewHandles orderGetIn true;
	_infHandles orderGetIn true;
	private _crewInVehHandles = _crewHandles select {!(vehicle _x isEqualTo _x)};
	private _infInVehHandles = _infHandles select {!(vehicle _x isEqualTo _x)};
	diag_log format ["Crew in vehicles: %1 / %2", count _crewInVehHandles, count _crewHandles];
	diag_log format ["Infantry in vehicles: %1 / %2", count _infInVehHandles, count _infHandles];
	((count _crewInVehHandles) == (count _crewHandles)) && ((count _infInVehHandles) == (count _infHandles))
};
//Select new leader
_vehGroupHandle selectLeader ((units _vehGroupHandle) select 2);
sleep 1;
private _wp0 = _vehGroupHandle addWaypoint [position _locTo, 10, 0, "Move here!"];
_wp0 setWaypointType "MOVE";
_vehGroupHandle setCurrentWaypoint _wp0;

//Start enemies script
private _oEnemiesScript = [_garConvoy, "AI_fnc_manageSpottedEnemies", []]
								call AI_fnc_startMediumLevelScript;
[globalEnemyMonitor, _oEnemiesScript] call sense_fnc_enemyMonitor_addScript;
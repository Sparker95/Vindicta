/*
Just my attempt to make a convoy to see how modules work!
This should be redone!
*/

params ["_locFrom", "_locTo", "_returnArray"];

//Get main garrison of the initial location
private _garFrom = _locFrom call loc_fnc_getMainGarrison;

//Other common variables
private _rid = 0; //ID of request
private _rarray = []; //Return data from request

//Find needed units

//Find groups with troops
private _infGroupIDs = [_garFrom, G_GT_idle] call gar_fnc_findGroups;
diag_log format ["convoy.sqf: found infantry groups for convoy: %1", _infGroupIDs];

//Find unarmed vehicles
private _unarmedVehUnitData = [_garFrom, T_VEH, T_VEH_truck_inf] call gar_fnc_findUnits;
_unarmedVehUnitData = [_unarmedVehUnitData select 0]; //We need only one truck for now
diag_log format ["convoy.sqf: found unarmed vehicles for convoy: %1", _unarmedVehUnitData];
/*
{
	_unarmedVehArray pushBack [_x, [], -1]; //[_vehUnitData, _crewUnitData, _infGroupID]
} forEach _allTrucks;
*/

//Find a driver unarmed vehicles, assign trucks to groups
private _unarmedVehGroupIDs = [];
{
	private _truck = _x;
	_rarray = []; //Return array
	
	_rid = [_garFrom, G_GT_veh_non_static, _rarray] call gar_fnc_addNewEmptyGroup;
	waitUntil {sleep 0.1; [_garFrom, _rid] call gar_fnc_requestDone};
	private _truckGroupID = _rarray select 0;
	_unarmedVehGroupIDs pushBack _truckGroupID;
	diag_log format ["Truck's group ID: %1", _truckGroupID];
	
	//Find a driver for the truck
	private _infGroupID = _infGroupIDs select 0;
	private _infGroupUnits = [_garFrom, _infGroupID] call gar_fnc_getGroupAliveUnits;
	private _truckDriver = _infGroupUnits select ((count _infGroupUnits) - 1);
	//Move the truck and its driver to new group
	[_garFrom, _truck, _truckGroupID, false] call gar_fnc_joinGroup;
	_rid = [_garFrom, _truckDriver, _truckGroupID, true] call gar_fnc_joinGroup;
	waitUntil {sleep 0.1; [_garFrom, _rid] call gar_fnc_requestDone};
	diag_log format ["New truck's group structure after moving driver: %1", [_garFrom, _truckGroupID] call gar_fnc_getGroup];
} forEach _unarmedVehUnitData;


//Find armed vehicles
private _armedVehUnitData = [_garFrom, T_VEH, T_VEH_MRAP_unarmed] call gar_fnc_findUnits;
_armedVehUnitData append ([_garFrom, T_VEH, T_VEH_MRAP_HMG] call gar_fnc_findUnits);
_armedVehUnitData append ([_garFrom, T_VEH, T_VEH_MRAP_GMG] call gar_fnc_findUnits);
_armedVehUnitData append ([_garFrom, T_VEH, T_VEH_APC] call gar_fnc_findUnits);
_armedVehUnitData append ([_garFrom, T_VEH, T_VEH_IFV] call gar_fnc_findUnits);
private _armedVehGroupIDs = [];

if(count _armedVehUnitData > 1) then
{
	_armedVehUnitData = [_armedVehUnitData select 0, _armedVehUnitData select 1];
}
else
{
	_armedVehUnitData = [_armedVehUnitData select 0];
};
diag_log format ["convoy.sqf: found armed vehicles for convoy: %1", _armedVehUnitData];
{
	_armedVehGroupIDs pushBack ([_garFrom, _x] call gar_fnc_getUnitGroupID);
}forEach _armedVehUnitData;


//Create new garrison object for the convoy
private _garConvoy = [] call gar_fnc_createGarrison;
gGarConvoy = _garConvoy;
[_garConvoy, "Convoy garrison"] call gar_fnc_setName;
[_garConvoy, _garFrom call gar_fnc_getSide] call gar_fnc_setSide;
[_garConvoy, _locFrom] call gar_fnc_setLocation;
//Spawn the new garrison so that units that will join it will spawn as well
_garConvoy call gar_fnc_spawnGarrison;

//Move all the groups to the new garrison
{
	_rid = [_garFrom, _garConvoy, _x, _rarray] call gar_fnc_moveGroup;
	waitUntil {sleep 0.01; [_garFrom, _rid] call gar_fnc_requestDone};
	_unarmedVehGroupIDs set [_foreachindex, _rarray select 0];
} forEach _unarmedVehGroupIDs;
{
	_rid = [_garFrom, _garConvoy, _x, _rarray] call gar_fnc_moveGroup;
	waitUntil {sleep 0.01; [_garFrom, _rid] call gar_fnc_requestDone};
	_armedVehGroupIDs set [_foreachindex, _rarray select 0];
} forEach _armedVehGroupIDs;
{
	_rid = [_garFrom, _garConvoy, _x, _rarray] call gar_fnc_moveGroup;
	waitUntil {sleep 0.01; [_garFrom, _rid] call gar_fnc_requestDone};
	_infGroupIDs set [_foreachindex, _rarray select 0];
} forEach _infGroupIDs;

diag_log format ["convoy.sqf: after moving vehicle groups: _unarmedVehGroupIDs: %1, _armedVehGroupIDs: %2, _infGroupIDs: %3", _unarmedVehGroupIDs, _armedVehGroupIDs, _infGroupIDs];

//Create arrays for AI_fnc_landConvoy
private _armedVehGroups = [];
private _unarmedVehGroups = [];
{
	_armedVehGroups pushBack [_x, -1];
} forEach _armedVehGroupIDs;
{
	_unarmedVehGroups pushBack [_x, _infGroupIDs select _foreachindex];
} forEach _unarmedVehGroupIDs;

//Start the AI_fnc_landConvoy script
diag_log format ["convoy.sqf: _armedVehGroups: %1, _unarmedVehGroups: %2", _armedVehGroups, _unarmedVehGroups];
private _extraParams =  [_armedVehGroups, _unarmedVehGroups, getPos _locTo];
private _oConvoyScript = [_garConvoy, "AI_fnc_landConvoy", _extraParams] call AI_fnc_startMediumLevelScript;

//Start enemies script
private _oEnemiesScript = [_garConvoy, "AI_fnc_manageSpottedEnemies", []]
								call AI_fnc_startMediumLevelScript;
[globalEnemyMonitor, _oEnemiesScript] call sense_fnc_enemyMonitor_addScript;

//Return the convoy garrison
diag_log "convoy.sqf: exit!";
_returnArray set [0, _garConvoy];
/*
_locTransport = (alllocations select 8);
_locCargo = (alllocations select 7);
[_locTransport, _locCargo, (alllocations select 9)] spawn compile preprocessfilelinenumbers "Commander\convoy2.sqf";
*/


params ["_locTransport", "_locCargo", "_locTo"];

private _garTransport_old = _locTransport call loc_fnc_getMainGarrison;
private _garCargo_old = _locCargo call loc_fnc_getMainGarrison;

//Other common variables
private _rid = 0; //ID of request
private _rarray = []; //Return data from request

//Create new transport garrison
private _garTransport = [] call gar_fnc_createGarrison;
garTransport = _garTransport;
[_garTransport, "Convoy transport gar."] call gar_fnc_setName;
[_garTransport, _garTransport_old call gar_fnc_getSide] call gar_fnc_setSide;
[_garTransport, _locTransport] call gar_fnc_setLocation;
//Spawn the new garrison so that units that will join it will spawn as well
_garTransport call gar_fnc_spawnGarrison;
//Move all units from location's garrison into a new garrison
_rid = [_garTransport_old, _garTransport] call gar_fnc_mergeGarrisons;
waitUntil {sleep 0.1; [_garTransport_old, _rid] call gar_fnc_requestDone};

//Create new cargo garrison
private _garCargo = [] call gar_fnc_createGarrison;
garCargo = _garCargo;
[_garCargo, "Convoy cargo gar."] call gar_fnc_setName;
[_garCargo, _garCargo_old call gar_fnc_getSide] call gar_fnc_setSide;
[_garCargo, _locCargo] call gar_fnc_setLocation;
//Spawn the new garrison so that units that will join it will spawn as well
_garCargo call gar_fnc_spawnGarrison;
_rid = [_garCargo_old, _garCargo] call gar_fnc_mergeGarrisons;
waitUntil {sleep 0.1; [_garCargo_old, _rid] call gar_fnc_requestDone};


//Restart the AI scripts for the initial location
_locTransport call loc_fnc_restartEnemiesScript;
_locTransport call loc_fnc_restartAlertStateScript;

_locCargo call loc_fnc_restartEnemiesScript;
_locCargo call loc_fnc_restartAlertStateScript;


//Start enemies script
/*
private _oEnemiesScript = [[_garConvoy], "AI_fnc_manageSpottedEnemies", []]
								call AI_fnc_startMediumLevelScript;
[globalEnemyMonitor, _oEnemiesScript] call sense_fnc_enemyMonitor_addScript;
*/

//Add tasks

//==== LOAD task ====
private _oTaskLoad = [_garTransport, "LOAD", [_garCargo], "Load task"] call AI_fnc_task_create;
taskLoad = _oTaskLoad;
_oTaskLoad call AI_fnc_task_start;

//Wait until LOAD is done
waitUntil
{
	sleep 1;
	(_oTaskLoad call AI_fnc_task_getState == "SUCCESS")
};
diag_log "======== LOAD TASK DONE ========";

//==== MOVE task ====
private _oTaskMove = [_garTransport, "MOVE", [_locTo], "Move task"] call AI_fnc_task_create;
taskMove = _oTaskMove;
_oTaskMove call AI_fnc_task_start;
waitUntil
{
	sleep 1;
	(_oTaskMove call AI_fnc_task_getState == "SUCCESS")
};
diag_log "======== MOVE TASK DONE ========";

//==== UNLOAD task ====
private _oTaskUnload = [_garTransport, "UNLOAD", [], "Unload task"] call AI_fnc_task_create;
taskUnload = _oTaskUnload;
_oTaskUnload call AI_fnc_task_start;
waitUntil
{
	sleep 1;
	(_oTaskUnload call AI_fnc_task_getState == "SUCCESS")
};
diag_log "======== UNLOAD TASK DONE ========";

//==== MERGE task ====
private _oTaskMerge = [_garCargo, "MERGE", [_locTo], "Merge task"] call AI_fnc_task_create;
taskMerge = _oTaskMerge;
_oTaskMerge call AI_fnc_task_merge;
waitUntil
{
	sleep 1;
	(_oTaskMerge call AI_fnc_task_getState == "SUCCESS")
};
diag_log "======== MERGE TASK DONE ========";

//==== MOVE task ====
private _oTaskMove = [_garTransport, "MOVE", [getPos _locTransport], "Move task"] call AI_fnc_task_create;
taskMove = _oTaskMove;
_oTaskMove call AI_fnc_task_start;
waitUntil
{
	sleep 1;
	(_oTaskMove call AI_fnc_task_getState == "SUCCESS")
};
diag_log "======== MOVE TASK DONE ========";

//==== MERGE task ====
private _oTaskMerge = [_garTransport, "MERGE", [_locTransport], "Merge task"] call AI_fnc_task_create;
taskMerge = _oTaskMerge;
_oTaskMerge call AI_fnc_task_merge;
waitUntil
{
	sleep 1;
	(_oTaskMerge call AI_fnc_task_getState == "SUCCESS")
};
diag_log "======== MERGE TASK DONE ========";

//The end!
diag_log "convoy2.sqf: exit!";

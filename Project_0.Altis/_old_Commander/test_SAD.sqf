/*
_locAttack = (alllocations select 0);
[_locAttack, [3500, 2700, 0], 450] spawn compile preprocessfilelinenumbers "Commander\test_SAD.sqf";
*/

params ["_loc", "_target", "_radius"];

private _gar = _loc call loc_fnc_getMainGarrison;

//Other common variables
private _rid = 0; //ID of request
private _rarray = []; //Return data from request

//Create new transport garrison
private _garAttack = [] call gar_fnc_createGarrison;
garAttack = _garAttack;
[_garAttack, "Attack gar."] call gar_fnc_setName;
[_garAttack, _gar call gar_fnc_getSide] call gar_fnc_setSide;
[_garAttack, _loc] call gar_fnc_setLocation;
//Spawn the new garrison so that units that will join it will spawn as well
_garAttack call gar_fnc_spawnGarrison;
//Move all units from location's garrison into a new garrison
_rid = [_gar, _garAttack] call gar_fnc_mergeGarrisons;
waitUntil {sleep 0.1; [_gar, _rid] call gar_fnc_requestDone};

//Restart the AI scripts for the initial location
_loc call loc_fnc_restartEnemiesScript;
_loc call loc_fnc_restartAlertStateScript;

//Start enemies script

private _oEnemiesScript = [[_garAttack], "AI_fnc_manageSpottedEnemies", []]
								call AI_fnc_startMediumLevelScript;
[globalEnemyMonitor, _oEnemiesScript] call sense_fnc_enemyMonitor_addScript;


//Add tasks

//==== MOVE task ====
private _oTaskMove = [_garAttack, "MOVE", [_target, _radius], "Move task"] call AI_fnc_task_create;
taskMove = _oTaskMove;
_oTaskMove call AI_fnc_task_start;
waitUntil
{
	sleep 1;
	(_oTaskMove call AI_fnc_task_getState == "SUCCESS")
};
diag_log "======== MOVE TASK DONE ========";

//==== ATTACK task ====
private _oTaskSAD = [_garAttack, "SAD", [_target, _radius, 300], "SAD task"] call AI_fnc_task_create;
taskSAD = _oTaskSAD;
_oTaskSAD call AI_fnc_task_start;
waitUntil
{
	sleep 1;
	(_oTaskSAD call AI_fnc_task_getState == "SUCCESS")
};
diag_log "======== SAD TASK DONE ========";


//The end!
diag_log "test_SAD.sqf: exit!";

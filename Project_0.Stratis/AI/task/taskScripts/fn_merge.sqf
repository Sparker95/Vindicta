/*
Merges the garrison this task was assigned to with another garrison.

Task parameters:
[_dst]
_dst - the destination. Can be one of:
Garrison OBJECT 
Location OBJECT
*/

params ["_to"]; //Task object

private _gar = _to getVariable "AI_garrison";
private _taskParams = _to getVariable "AI_taskParams";

//Read task parameters
_taskParams params ["_dst"];
private _garDst = _dst; //It can be garrison or location
if (_dst call loc_fnc_isLocation) then
{
	_garDst = _dst call loc_fnc_getMainGarrison;
};
diag_log format ["==== Merging garrison! Destination: %1, %2", _garDst, _garDst getVariable "g_name"];

private _rid = [_gar, _garDst] call gar_fnc_mergeGarrisons;
waitUntil{[_gar, _rid] call gar_fnc_requestDone};

//If the garrison was merged into a location, restart its AI scripts
if (_dst call loc_fnc_isLocation) then
{
	diag_log "RESTARTING AI SCRIPTS!";
	//Start enemies management script
	_dst call loc_fnc_restartEnemiesScript;
	//Start alert state script
	_dst call loc_fnc_restartAlertStateScript;
};

_to setVariable ["AI_taskState", "SUCCESS", false];
/*
Merges the garrison this task was assigned to with another garrison.
*/

params ["_to"]; //Task object

private _gar = _to getVariable "AI_garrison";
private _taskParams = _to getVariable "AI_taskParams";
_taskParams params ["_garDst"];
diag_log format ["==== Merging garrison! Destination: %1, %2", _garDst, _garDst getVariable "g_name"];

private _rid = [_gar, _garDst] call gar_fnc_mergeGarrisons;
waitUntil{[_gar, _rid] call gar_fnc_requestDone};

_to setVariable ["AI_taskState", "SUCCESS", false];
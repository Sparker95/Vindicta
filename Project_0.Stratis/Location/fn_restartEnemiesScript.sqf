/*
This function restarts the script that handles spotted enemies.
*/

params ["_loc"];

waitUntil {(_loc getVariable ["l_AIScriptsMutex", 0]) == 0};
private _gar = _loc getVariable ["l_garrison_main", objNull];

//Lock the mutex
_loc setVariable ["l_AIScriptsMutex", 1, false];

//Stop the AI script
private _oEnemiesScript = _loc getVariable ["l_oAIEnemiesScript", objNull];
if(!isNull _oEnemiesScript) then //Check if another script is already running
{
	[globalEnemyMonitor, _oEnemiesScript] call sense_fnc_enemyMonitor_removeScript;
	[_oEnemiesScript] call AI_fnc_stopMediumLevelScript;
};
private _spawned = _gar call gar_fnc_isSpawned;
if (_spawned) then
{
	_oEnemiesScript = [[_gar], "AI_fnc_manageSpottedEnemies", [_loc, true]]
									call AI_fnc_startMediumLevelScript;
	[globalEnemyMonitor, _oEnemiesScript] call sense_fnc_enemyMonitor_addScript;
}
else
{
	_oEnemiesScript = objNull;
};
_loc setVariable ["l_oAIEnemiesScript", _oEnemiesScript, false];

//Release the mutex
_loc setVariable ["l_AIScriptsMutex", 0, false];

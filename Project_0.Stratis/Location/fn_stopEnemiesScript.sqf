/*
This function starts an AI alert state script depending on location's alert state.
Also a check on already running script is being performed, so it's possible to call this function to restart the script.
*/

params ["_loc"];

waitUntil {(_loc getVariable ["l_AIScriptsMutex", 0]) == 0};

//Lock the mutex
_loc setVariable ["l_AIScriptsMutex", 1, false];

//Remove the script
private _oEnemiesScript = _loc getVariable ["l_oAIEnemiesScript", objNull];
_oEnemiesScript call sense_fnc_enemyMonitor_removeScript;

//Stop the AI script
if(!isNull _oEnemiesScript) then //Check if another script is already running
{
	[_oEnemiesScript] call AI_fnc_stopMediumLevelScript;
};

//Release the mutex
_loc setVariable ["l_AIScriptsMutex", 0, false];

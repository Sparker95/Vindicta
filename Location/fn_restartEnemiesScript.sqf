/*
This function restarts the script that handles spotted enemies.
*/

params ["_loc"];

waitUntil {(_loc getVariable ["l_AIScriptsMutex", 0]) == 0};

//Lock the mutex
_loc setVariable ["l_AIScriptsMutex", 1, false];

//Stop the AI script
private _oEnemiesScript = _loc getVariable ["l_oAIEnemiesScript", objNull];
if(!isNull _oEnemiesScript) then //Check if another script is already running
{
	[_oEnemiesScript] call AI_fnc_stopMediumLevelScript;
};
_oEnemiesScript = [_gar, "AI_fnc_manageSpottedEnemies", [_loc, true]]
								call AI_fnc_startMediumLevelScript;
//Later we will need to access this object to get data from the AI managing script
_loc setVariable ["l_oAIEnemiesScript", _oEnemiesScript, false];

//Release the mutex
_loc setVariable ["l_AIScriptsMutex", 0, false];

_oEnemiesScript
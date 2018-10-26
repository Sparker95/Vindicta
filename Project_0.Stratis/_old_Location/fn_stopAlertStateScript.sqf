/*
This function stops an AI alert state script.
*/

params ["_loc"];

waitUntil {(_loc getVariable ["l_AIScriptsMutex", 0]) == 0};

//Lock the mutex
_loc setVariable ["l_AIScriptsMutex", 1, false];

//Stop the AI script
private _oAlertStateScript = _loc getVariable ["l_oAIAlertStateScript", objNull];
if(!isNull _oAlertStateScript) then //Check if another script is already running
{
	[_oAlertStateScript] call AI_fnc_stopMediumLevelScript;
};

//Release the mutex
_loc setVariable ["l_AIScriptsMutex", 0, false];

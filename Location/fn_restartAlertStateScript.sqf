/*
This function starts an AI alert state script depending on location's alert state.
Also a check on already running script is being performed, so it's possible to call this function to restart the script.
*/

params ["_loc"];

waitUntil {(_loc getVariable ["l_AIScriptsMutex", 0]) == 0};

//Lock the mutex
_loc setVariable ["l_AIScriptsMutex", 1, false];

//Start AI scripts
private _gar = _loc getVariable ["l_garrison_main", objNull];
private _alertState = _loc getVariable ["l_alertState", 0];
private _alertStateScriptNames = [];
_alertStateScriptNames set [LOC_AS_none, "AI_fnc_alertStateSafe"];
_alertStateScriptNames set [LOC_AS_safe, "AI_fnc_alertStateSafe"];
_alertStateScriptNames set [LOC_AS_aware, "AI_fnc_alertStateAware"];
_alertStateScriptNames set [LOC_AS_combat, "AI_fnc_alertStateCombat"];
private _newScriptName = _alertStateScriptNames select _alertState;

private _oAlertStateScript = _loc getVariable ["l_oAIAlertStateScript", objNull];
if(!isNull _oAlertStateScript) then //Check if another script is already running
{
	[_oAlertStateScript] call AI_fnc_stopMediumLevelScript;
};
_oAlertStateScript = [_gar, _newScriptName, [_loc, true]] call AI_fnc_startMediumLevelScript;
_loc setVariable ["l_oAIAlertStateScript", _oAlertStateScript, false];

//Release the mutex
_loc setVariable ["l_AIScriptsMutex", 0, false];
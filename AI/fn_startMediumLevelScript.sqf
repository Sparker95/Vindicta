/*
This function starts a medium level AI script for specified garrison.

Parameters:
_gar - the garrison object for which the script will be started
_scriptName - the name of the script to startLoadingScreen
_extraParams - extra script-specific parameters to be passed to the spawned script
*/

params ["_gar", "_scriptName", "_extraParams"];

diag_log format ["Starting AI script: %1", _scriptName];

private _scriptObject = groupLogic createUnit ["LOGIC", [6, 6, 6], [], 0, "NONE"]; //logic object

private _scriptHandle = [_scriptObject, _extraParams] call (call compile _scriptName);
//Every time a new script is spawned, it should be added to this array
_scriptObject setVariable ["AI_hScripts", [_scriptHandle], false];
_scriptObject setVariable ["AI_garrison", _gar];

_scriptObject
/*
This function starts a medium level AI script for specified garrisons.

Parameters:
_gars - array of garrison objects for which the script will be started
_scriptName - the name of the script to startLoadingScreen
_extraParams - extra script-specific parameters to be passed to the spawned script
*/

params ["_gars", "_scriptName", "_extraParams"];

diag_log format ["Starting AI script: %1", _scriptName];

//private _scriptObject = groupLogic createUnit ["LOGIC", [6, 6, 6], [], 0, "NONE"]; //logic object
private _scriptObject = "Sign_Arrow_Large_Pink_F" createVehicle [6, 6, 6];
hideObjectGlobal _scriptObject;

/*
We CALL the medium level script, not SPAWN it. Inside the script being called, there is initialization, then a script is being SPAWNED and being returned to _scriptHandle.
This way we can do necessary initialization before returning the script handle.
*/
_scriptObject setVariable ["AI_garrisons", _gars];
_scriptObject setVariable ["AI_hScripts", [], false];
private _scriptHandle = [_scriptObject, _extraParams] call (call compile _scriptName);
//Every time a new script is spawned, it should be added to this array

_scriptObject

/*
This function adds a script handle to an array of a medium level script object.
_stopScript - the script that will be called if the scriptHandle needs to be terminated.
ARRAY: [_params, _scriptName]
	_params - the parameters that will be passed to the script
	_scriptName - the name of the script that will be called
*/

params ["_scriptObject", "_scriptHandle", ["_stopScriptParams", []], ["_stopScriptName", ""]];

private _scripts = _scriptObject getVariable ["AI_hScripts", []];
_scripts pushBack [_scriptHandle, _stopScriptParams, _stopScriptName];
_scriptObject setVariable ["AI_hScripts", _scripts];

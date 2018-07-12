/*
Starts the behaviour _script for specified _groups. The _params are passed to the _script when it is spawned.
*/

params ["_groups", "_params", "_script"];

private _scriptHandle = [_groups, _params] spawn _script;
(_groups select 0) setVariable ["AI_hBS", _scriptHandle]; //We'll use it later to terminate the script

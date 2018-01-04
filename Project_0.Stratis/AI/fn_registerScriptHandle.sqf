/*
This function adds a script handle to an array of a medium level script object.
*/

params ["_scriptObject", "_scriptHandle"];

private _scripts = _scriptObject getVariable ["AI_hScripts", []];
_scripts pushBack _scriptHandle;
_scriptObject setVariable ["AI_hScripts", _scripts];
/*
This function starts the AI_fnc_manageSpottedEnemies.sqf script.
*/

params ["_lo"];

private _loc = _lo getVariable ["g_location", objNull];
_hScript = [_lo, _loc, _lo getVariable ["g_manageAlertState", false]] spawn AI_fnc_manageSpottedEnemies;
_lo setVariable ["g_enemiesThreadHandle", _hScript, false];

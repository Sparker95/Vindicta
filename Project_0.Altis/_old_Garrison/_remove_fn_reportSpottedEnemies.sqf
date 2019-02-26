/*
This script is used to report spotted enemies to garrison object.
Later the reported enemies will be read from garrison object by other mission's modules.
*/

params ["_lo", "_enemiesObjects", "_enemiesPos", ["_debug", false]];

_lo setVariable ["g_enemiesObjects", _enemiesObjects];
_lo setVariable ["g_enemiesPos", _enemiesPos];

if(_debug) then {diag_log format ["fn_reportSpottedEnemies.sqf: garrison: %1, reported enemies: %2", _lo getVariable ["g_name", ""], _enemiesObjects];};
if(_debug) then {diag_log format ["fn_reportSpottedEnemies.sqf: garrison: %1, reported pos: %2", _lo getVariable ["g_name", ""], _enemiesPos];};
//_lo setVariable ["g_enemiesTime", ];

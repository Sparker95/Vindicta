/*
Start the thread and attach it to the garrison logic object
return value:
true - success
false - failure
*/

#include "garrison.hpp"

params ["_lo", "_workTime", ["_debug", true]];

private _hThread = _lo getVariable ["g_threadHandle", scriptNull];

if(_hThread isEqualTo scriptNull) then
{
	_hThread = [_lo, _workTime, _debug] spawn gar_fnc_garrisonThread;
	_lo setVariable ["g_threadHandle", _hThread];
	if(_debug) then {diag_log format ["fn_startThread.sqf: starting a new thread for garrison: %1", _lo getVariable ["g_name", ""]];};
	true
}
else
{
	if(_debug) then {diag_log format ["fn_startThread.sqf: thread already started for garrison: %1", _lo getVariable ["g_name", ""]];};
	false
};

/*
Start the thread of this location.
*/

params ["_loc", ["_debug", true]];

private _hThread = _loc getVariable ["l_threadHandle", nil];

if(isNil "_hThread") then
{
	_hThread = [_loc] spawn loc_fnc_locationThread;
	_loc setVariable ["l_threadHandle", _hThread];
	if(_debug) then {diag_log format ["fn_startThread.sqf: starting a new thread for location: %1", _loc getVariable ["l_name", ""]];};
	true
}
else
{
	if(_debug) then {diag_log format ["fn_startThread.sqf: thread already started for location: %1", _loc getVariable ["l_name", ""]];};
	false
};
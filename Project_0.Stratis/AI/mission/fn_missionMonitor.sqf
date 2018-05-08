/*

*/

params [["_runOnce", false]];

while {true} do
{
	if(!_runOnce) then
	{
		sleep 10;
	};
	
	private _garEast = allGarrisons select {_x call gar_fnc_getSide == EAST};
	private _misEast = allMissions select {_x call AI_fnc_mission_getSide == EAST};
	private _garWest = allGarrisons select {_x call gar_fnc_getSide == WEST};
	private _misWest = allMissions select {_x call AI_fnc_mission_getSide == WEST};
	
	diag_log format ["<AI_MISSION> INFO: fn_missionMonitor.sqf: _garEast: %1", _garEast];
	diag_log format ["<AI_MISSION> INFO: fn_missionMonitor.sqf: _misEast: %1", _misEast];
	diag_log format ["<AI_MISSION> INFO: fn_missionMonitor.sqf: _garWest: %1", _garWest];
	diag_log format ["<AI_MISSION> INFO: fn_missionMonitor.sqf: _misWest: %1", _misWest];
	
	_misEast call AI_fnc_mission_unregisterAllGarrisons;
	[_misEast, _garEast] call AI_fnc_mission_registerGarrisons;
	[_misEast, _garEast] call AI_fnc_mission_startMissions;
	
	_misWest call AI_fnc_mission_unregisterAllGarrisons;
	[_misWest, _garWest] call AI_fnc_mission_registerGarrisons;
	[_misWest, _garWest] call AI_fnc_mission_startMissions;
	
	if(_runOnce) exitWith {};
};
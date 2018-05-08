/*
This function starts missions that have garrisons registered to them
*/

#define DEBUG

params ["_missions", "_garrisons"];

for "_i" from 0 to ((count _missions) - 1) do
{
	private _m = _missions select _i;
	#ifdef DEBUG
	diag_log format ["<AI_MISSION> INFO: fn_startMissions: checking mission: %1", _m getVariable "AI_m_name"];
	#endif
	//Check if any garrisons are registered to this mission
	private _gRegistered = _m call AI_fnc_mission_getRegisteredGarrisons;
	#ifdef DEBUG
	diag_log format ["<AI_MISSION> INFO: fn_startMissions: registered garrisons: %1", _gRegistered];
	#endif
	if (count _gRegistered > 0 && ((_m call AI_fnc_mission_getState) == "IDLE")) then
	{
		//Start the mission
		_m call AI_fnc_mission_start;
	};
};
#include "..\OOP_Light\OOP_Light.h"

// Adds an untie action to the unit locally
params ["_unit"];

[ 
	_unit,
	"Free the Civilian",
	"",
	"",
	"(_this distance _target < 2) && (alive _target) && (([_target] call civPresence_fnc_getUnitState) == 'arrested')",
	"(_this distance _target < 2) && (alive _target) && (([_target] call civPresence_fnc_getUnitState) == 'arrested')",
	{
		params ["_target", "_caller", "_actionId", "_arguments"];
		[player,_target, "release_start"] call  pr0_fnc_dialogue_create;
	}, // Code start
	
	{
		// Boost player's suspicion
		CALLSM2("undercoverMonitor", "boostSuspicion", player, 1.0);
	}, // Code progress

	{ 	// Code completed
		params ["_target", "_caller", "_actionId", "_arguments"];
		[_target,player, "release_finished"] call  pr0_fnc_dialogue_create;

		// Unarrest him
		[_target, false] remoteExecCall ["CivPresence_fnc_arrestUnit", 2, false];

		// Add activity here
		CALLSM("AICommander", "addActivity", [CALLM0(gGameMode, "getEnemySide") ARG getPos player ARG (10 + random 8)]);
	},

	{}, // Code interrupted
	[], // Arguments
	8,
	10000, 
	false, // Remove on completion
	false
] call BIS_fnc_holdActionAdd;
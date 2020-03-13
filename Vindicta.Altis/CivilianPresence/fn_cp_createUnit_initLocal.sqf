#include "..\OOP_Light\OOP_Light.h"

//called by server and run on all connected clients


params [["_unit",objNull,[objNull]]];

//add dialogue
[_unit, ["civilian"]] call pr0_fnc_dialogue_setDataSets;


//prevent the rest from running on headless clients
if(!hasInterface)exitWith{};

//add talk to action
_unit addAction [(("<img image='a3\ui_f\data\IGUI\Cfg\simpleTasks\types\talk_ca.paa' size='1' color = '#FFFFFF'/>") + ("<t size='1' color = '#FFFFFF'> Talk</t>")), // title
	{
		params ["_target", "_caller"];
		
		private _state = _target call pr0_fnc_cp_getUnitState;
		private _end_script = {};

		//stop unit from moving if he is not in panic
		if!(_state isEqualTo "panic")then{
			[_target, _caller, true] call pr0_fnc_cp_talkToServer;
			_end_script = {
				params ["_caller","_target"];
				[_target, _caller, false] call pr0_fnc_cp_talkToServer;
			};
		};
		
		[_caller,_target,"intro_hello",_end_script] call pr0_fnc_dialogue_create;

	}, // Script
	0, // Arguments
	9000, // Priority
	true, // ShowWindow
	true, //hideOnUse
	"", //shortcut
	"", //condition
	7, //radius
	false, //unconscious
	"", //selection
	""
]; //memoryPoint




//add untie
[ 
	_unit,
	"Free the Civilian",
	"",
	"",
	"(_this distance _target < 2) && (alive _target) && (([_target] call pr0_fnc_cp_getUnitState) == 'arrested')",
	"(_this distance _target < 2) && (alive _target) && (([_target] call pr0_fnc_cp_getUnitState) == 'arrested')",
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
		[player,_target, "release_finished"] call  pr0_fnc_dialogue_create;

		// Unarrest him
		[_target, false] remoteExecCall ["pr0_fnc_cp_arrestUnit", 2, false];

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
#include "..\common.h"

//called by server and run on all connected clients


params [["_unit",objNull,[objNull]]];

//prevent the rest from running on headless clients
if(!hasInterface)exitWith{};

//add talk to action
_unit addAction [(("<img image='a3\ui_f\data\IGUI\Cfg\simpleTasks\types\talk_ca.paa' size='1' color = '#FFFFFF'/>") + ("<t size='1' color = '#FFFFFF'> Talk</t>")), // title
	{
		params ["_target", "_caller"];
		
		private _state = _target call pr0_fnc_cp_getUnitState;

		if(_state isEqualTo "panic")exitWith{
			if(_target getVariable ["dialog_aimed_at",false])then{
				[_target, "Get away from me!", 1] call pr0_fnc_dialogue_createSentence;
			}else{
				[_target, "can't talk right now", 1] call pr0_fnc_dialogue_createSentence;
			};
		};

		private _end_script = {};
		private _dialogues = ["civilian"];
		if(_state isEqualTo "arrested")then{
			_dialogues pushBack "arrested";
		};

		//stop unit from moving if he is not in panic
		[_target, _caller, true] call pr0_fnc_cp_talkToServer;

		//lock dialogue from running a second time
		_target setVariable ["talkingTo",true];
		
		//disable stop moving after dialoge is over
		_end_script = {
			params ["_caller","_target"];
			[_target, _caller, false] call pr0_fnc_cp_talkToServer;
			_target setVariable ["talkingTo",false];
		};

		[_caller,_target,_dialogues, "intro_hello",_end_script] call pr0_fnc_dialogue_createConversation;

	}, // Script
	0, // Arguments
	9000, // Priority
	true, // ShowWindow
	false, //hideOnUse
	"", //shortcut
	"!(_target getVariable ['talkingTo',false])", //condition
	4.5, //radius
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
		[_target, [
			"Let me free you",
			"Let me help you",
			"I will untie you while the police are not watching",
			"Run away after I release you",
			"Tell your friends that rebels helped you today!"
		]] call  pr0_fnc_dialogue_createSentence;
	}, // Code start
	
	{
		// Boost player's suspicion
		CALLSM2("undercoverMonitor", "boostSuspicion", player, 1.0);
	}, // Code progress

	{ 	// Code completed
		params ["_target", "_caller", "_actionId", "_arguments"];
		[_target, [
			"Thanks man!",
			"Thank you!",
			"I will never forget that you helped me!"
		]] call  pr0_fnc_dialogue_createSentence;

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
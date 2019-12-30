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
		private _text = selectRandom [
			"Let me free you",
			"Let me help you",
			"I will untie you while the police are not watching",
			"Run away after I release you",
			"Tell your friends that rebels helped you today!"
		];
		[player, _text, _target] call  Dialog_fnc_hud_createSentence;
	}, // Code start
	
	{}, // Code progress

	{ 	// Code completed
		params ["_target", "_caller", "_actionId", "_arguments"];
		private _text = selectRandom [
			"Thanks man!",
			"Thank you!",
			"I will never forget that you helped me!"
		];
		[_target, _text, player] call  Dialog_fnc_hud_createSentence;

		// Unarrest him
		[_target, false] call CivPresence_fnc_arrestUnit;

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
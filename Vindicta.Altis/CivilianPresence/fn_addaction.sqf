params [["_unit",objNull,[objNull]]];

if(!hasInterface)exitWith{};

[_unit, ["civilian"]] call pr0_fnc_dialogue_setDataSets;

_unit addAction [(("<img image='a3\ui_f\data\IGUI\Cfg\simpleTasks\types\talk_ca.paa' size='1' color = '#FFFFFF'/>") + ("<t size='1' color = '#FFFFFF'> Talk</t>")), // title
	{
		params ["_target", "_caller"];

		[_target, _caller, true] call CivPresence_fnc_talkToServer;
		[_caller,_target,"intro_hello",{
			//code that runs after dialogue is over
			params ["_caller","_target"];
			[_target, _caller, false] call CivPresence_fnc_talkToServer;
		}] call pr0_fnc_dialogue_create;
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
		
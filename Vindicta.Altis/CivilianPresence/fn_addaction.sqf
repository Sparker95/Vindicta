params [["_unit",objNull,[objNull]]];

if(!hasInterface)exitWith{};

[_unit, ["civilian"]] call pr0_fnc_dialogue_setDataSets;

_unit addAction [(("<img image='a3\ui_f\data\IGUI\Cfg\simpleTasks\types\talk_ca.paa' size='1' color = '#FFFFFF'/>") + ("<t size='1' color = '#FFFFFF'> Talk</t>")), // title
	{
		params ["_target", "_caller"];
		
		private _state = _target call CivPresence_fnc_getUnitState;
		private _end_script = {};

		//stop unit from moving if he is not in panic
		if!(_state isEqualTo "panic")then{
			[_target, _caller, true] call CivPresence_fnc_talkToServer;
			_end_script = {
				params ["_caller","_target"];
				[_target, _caller, false] call CivPresence_fnc_talkToServer;
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
		
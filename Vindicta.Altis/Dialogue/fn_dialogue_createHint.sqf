#include "defineCommon.inc"

/*
    By: Jeroen Notenbomer

    Create simple hint sentence and show it on everyones screen

	Input:
		_unit [Object]:
		_sentence [String]:
	Output:
		nil
*/

params [
	["_unit",objNull,[objNull]],
	["_sentence","",["",[]]]
];

[_unit, _sentence, -1] call pr0_fnc_dialogue_HUD_createSentence;

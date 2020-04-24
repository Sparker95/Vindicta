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

_sentence = "(" + _sentence + ")"; 

if(_unit in Allplayers)then{
	[_unit, _sentence, 0] remoteExecCall ["pr0_fnc_dialogue_HUD_createSentence",_unit];
};


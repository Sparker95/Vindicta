#include "defineCommon.inc"


/*
    By: Jeroen Notenbomer

    Create simple spoken sentence and show it on everyones screen

	Input:
		_unit [Object]: 
		_sentence [String]: 
		_loudness [Float];
	Output:
		nil
*/


params [
	["_unit",objNull,[objNull]],
	["_sentence","",["",[]]],
	["_loudness",1,[0]]
];

if(!alive _unit || {_unit getVariable ["ace_isunconscious",false]})exitWith{};

if(_sentence isEqualType [])then{
	_sentence = selectRandom _sentence;
};

{
	if(_x distance _unit < (FLOAT_MAX_LISTENING_DISTANCE *_loudness) )then{
		[_unit,_sentence,_loudness] remoteExecCall ["pr0_fnc_dialogue_HUD_createSentence",_x];
	};
}forEach (Allplayers - entities "HeadlessClient_F");
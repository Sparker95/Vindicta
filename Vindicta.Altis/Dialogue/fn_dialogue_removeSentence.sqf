#include "defineCommon.inc"


params ["_ctrl_sentence"];

disableSerialization;
private _display = findDisplay 46;

//remove from list
call {
	private _ctrl_sentences = _display getvariable ["pr0_dialogue_sentence_list" ,[]];
	_ctrl_sentences = _ctrl_sentences - [_ctrl_sentence];
	_display setvariable ["pr0_dialogue_sentence_list" ,_ctrl_sentences];
	if(count _ctrl_sentences == 0)then{
		call pr0_fnc_dialogue_removeHUD;
	};
};

//remove sentence from icon list and remove icon if no other sentence uses it.
call {
	private _ctrl_icon = _ctrl_sentence getVariable ["_ctrl_icon",controlNull];
	private _ctrl_sentences = _ctrl_icon getVariable ["_ctrl_sentences", []];

	if(count _ctrl_sentences == 1)then{
		private _ctrl_icons = _display getvariable ["pr0_dialogue_icon_list" ,[]];
		_ctrl_icons = _ctrl_icons - [_ctrl_icon];
		_display setvariable ["pr0_dialogue_icon_list" ,_ctrl_icons];
		
		ctrlDelete _ctrl_icon;//icon is not used anymore
	}else{	
		_ctrl_sentences = _ctrl_sentences - [_ctrl_sentence];
		_ctrl_icon setVariable ["_ctrl_sentences", _ctrl_sentences];
	};
};

//remove sentence
ctrlDelete _ctrl_sentence;
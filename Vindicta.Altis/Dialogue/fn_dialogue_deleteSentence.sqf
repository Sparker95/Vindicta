#include "defineCommon.inc"


params ["_ctrl_sentence"];

disableSerialization;
private _display = findDisplay 46;

//remove from list
private _ctrl_sentences = _display getvariable ["pr0_dialogue_sentence_list" ,[]];
_ctrl_sentences = _ctrl_sentences - [_ctrl_sentence];
_display setvariable ["pr0_dialogue_sentence_list" ,_ctrl_sentences];
if(count _ctrl_sentences == 0)then{
	call pr0_fnc_dialogue_deleteHUD;
};

//resize background
private _hud_size = 0;
{
	private _ctrl_sentence = _x;
	private _size_y = (ctrlPosition _ctrl_sentence) # 3;
	_hud_size = _hud_size + _size_y;
}forEach _ctrl_sentences;

private _hud =  _display getvariable ["pr0_dialogue_hud" ,controlNull];
_hud ctrlSetPosition [0, FLOAT_POS_Y - _hud_size, 1, _hud_size];
_hud ctrlCommit FLOAT_FADE_TIME;


//remove sentence from icon list and remove icon if no other sentence uses it.
private _ctrl_icon = _ctrl_sentence getVariable ["_ctrl_icon",controlNull];
private _ctrl__icon_sentences = _ctrl_icon getVariable ["_ctrl_sentences", []];
if(count _ctrl__icon_sentences == 1)then{
	private _ctrl_icons = _display getvariable ["pr0_dialogue_icon_list" ,[]];
	_ctrl_icons = _ctrl_icons - [_ctrl_icon];
	_display setvariable ["pr0_dialogue_icon_list" ,_ctrl_icons];
	
	ctrlDelete _ctrl_icon;//icon is not used anymore
}else{	
	_ctrl__icon_sentences = _ctrl__icon_sentences - [_ctrl_sentence];
	_ctrl_icon setVariable ["_ctrl_sentences", _ctrl__icon_sentences];
};

//remove sentence
ctrlDelete _ctrl_sentence;
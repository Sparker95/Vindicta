#include "defineCommon.inc"

/*
    By: Jeroen Notenbomer

    Update text of a sentence.

	Input:
		_ctrl_sentence: Control of the sentence
	Output:
		nil
*/

params [["_ctrl_sentence",controlNull,[controlNull]]];

disableSerialization;

private _speaker = _ctrl_sentence getVariable ["_speaker",objNull];
private _listener = _ctrl_sentence getVariable ["_listener",objNull];
private _sentence = _ctrl_sentence getVariable ["_sentence",""];
private _options = _ctrl_sentence getVariable ["_options",[]];
private _type = _ctrl_sentence getVariable ["_type", TYPE_SENTENCE];

private _display = ctrlParent _ctrl_sentence;

private _color = [side _speaker,false] call BIS_fnc_sideColor; // Some colors don't look readable...
private _colorHTML = _color call BIS_fnc_colorRGBtoHTML;
private _colorTextHTML = "#FFFFFF";


diag_log str ["sentenceUpdateText",_sentence];

//when player is talking it will show up different
if(_speaker isequalto player)then{
	_ctrl_sentence ctrlSetStructuredText parseText format ["<t font='RobotoCondensed' align = 'right' size = '1.05'><t color = '#FFA300'>%1",_sentence];
}else{
	private _structedText =  parseText format ["<t font='RobotoCondensed' align = 'left' size = '1.05'><t color = '%1'>%2:</t> <t color = '%3'>%4",_colorHTML,name _speaker,_colorTextHTML,_sentence];

	if(_type == TYPE_SENTENCE)then{
		_ctrl_sentence ctrlSetStructuredText  _structedText;
	}else{ //question!
	
		//there might already be a question on the screen. We dont want to have two answers with the same number.
		//previous open question has 3 answers 1,2,3. When we create a new question we want to number the answers 4,5,...
		
		private _ctrl_questions = _display getvariable ["pr0_dialogue_question_list" ,[]];
		private _answer_nr = 1;
		{
			if(_x isEqualTo _ctrl_sentence)exitWith{};
			_answer_nr = _answer_nr + count (_x getVariable ["_options",[]])
		}forEach _ctrl_questions;
		
		diag_log str ["_options",_options];
		
		{
			_structedText = composeText [_structedText, lineBreak," - ", str (_forEachIndex + _answer_nr), ": ", _x#0];
		}forEach _options;
		
		private _pos = ctrlposition _ctrl_sentence;
		_pos set [3, (count _options + 1) * FLOAT_TEXT_HIGHT];
		_ctrl_sentence ctrlsetposition _pos;
		_ctrl_sentence ctrlCommit 0;
		
		_ctrl_sentence ctrlSetStructuredText _structedText;
	};

};
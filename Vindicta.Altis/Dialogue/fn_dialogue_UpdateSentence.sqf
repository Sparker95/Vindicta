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
private _sentence = _ctrl_sentence getVariable ["_sentence",""];
private _answers = _ctrl_sentence getVariable ["_answers",[]];
private _type = _ctrl_sentence getVariable ["_type", TYPE_SENTENCE];
private _distance_normal = _ctrl_sentence getVariable ["_distance_normal",1];

private _display = ctrlParent _ctrl_sentence;

//when player is talking it will show up different
if(player isEqualTo _speaker)then{
	_ctrl_sentence ctrlSetStructuredText parseText format [
		"<t font='RobotoCondensed' align = 'right' size = '1.05'><t color = '#FFA300'>%1",_sentence
	];
}else{
	private _color_unit = [_speaker, player] select (_speaker isEqualTo player)  call pr0_fnc_dialogue_common_unitSideColor;
	private _structedText =  parseText format [
		"<t font='RobotoCondensed' align = 'left' size = '1.05'><t color = '%1' shadow = '2'>%2:</t> <t color = '#ffffff'>%3",
		_color_unit,["Unknown",name _speaker]select (player knowsAbout _speaker == 4),_sentence
	];

	if(_type == TYPE_SENTENCE)then{
		_ctrl_sentence ctrlSetStructuredText  _structedText;
	}else{ //question!
	
		//there might already be a question on the screen. We dont want to have two answers with the same number.
		//previous open question has 3 answers 1,2,3. When we create a new question we want to number the answers 4,5,...
		
		private _ctrl_questions = _display getvariable ["pr0_dialogue_question_list" ,[]];
		private _answer_nr = 1;
		{
			if(_x isEqualTo _ctrl_sentence)exitWith{};
			_answer_nr = _answer_nr + count (_x getVariable ["_answers",[]])
		}forEach _ctrl_questions;

		
		//add answers to structured text		
		{
			private _answer = _x;
			_structedText = composeText [
				_structedText,
				lineBreak,
				" - ",
				str (_forEachIndex + _answer_nr),
				": ",
				_answer#INDEX_ANSWER_TEXT
			];
		}forEach _answers;

		_ctrl_sentence ctrlSetStructuredText _structedText;
		_ctrl_sentence setVariable ["_size_y",(count _answers + 1) * FLOAT_TEXT_HIGHT];
		
	};
};

//update position for all sentences
private _ctrl_sentences = _display getvariable ["pr0_dialogue_sentence_list" ,[]];
private _pos_y = 0;
for "_i" from count _ctrl_sentences -1 to 0 step -1 do{
	private _ctrl_sentence = _ctrl_sentences#_i;
	private _size_y = _ctrl_sentence getVariable ["_size_y",0];
	
	_ctrl_sentence ctrlsetposition [0,FLOAT_POS_Y - _size_y - _pos_y,1,_size_y];
	_ctrl_sentence ctrlCommit FLOAT_SCROLL_TIME;

	_pos_y = _pos_y + _size_y;
};

//update hut size
private _hud = call pr0_fnc_dialogue_createHUD;		
_hud ctrlSetPosition [0, FLOAT_POS_Y - _pos_y, 1, _pos_y];
_hud ctrlSetFade 0;//might have started to fade so we set it to 0 again
_hud ctrlCommit FLOAT_SCROLL_TIME;
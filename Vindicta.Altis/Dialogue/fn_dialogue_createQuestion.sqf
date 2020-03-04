#include "defineCommon.inc"


params [["_speaker",objNull,[objNull]],["_text","",[""]],["_loudness",1,[0]],["_answers",[],[[]]]];


disableSerialization;
private _display = findDisplay 46;

//Create sentence with answers for player
private _ctrl_question = [_speaker,_text,_loudness,_answers] call pr0_fnc_dialogue_createSentence;
private _ctrl_questions = _display getvariable ["pr0_dialogue_question_list" ,[]];
_ctrl_questions pushBack _ctrl_question;
_display setvariable ["pr0_dialogue_question_list" ,_ctrl_questions];



//-----------------------------------------------------------
//						Create keyevent 					|
//-----------------------------------------------------------

private _keyDownEvent = _display getVariable "pr0_dialogue_keyDownEvent";
if(isNil "_keyDownEvent")then{
	private _keyDownEvent = _display displayAddEventHandler ["KeyDown", { 
		params ["_display", "_key", "_shift", "_ctrl", "_alt"];
		_key = _key-1;//normalize to number on keyboard key_1 == 2
		if (_key >0 && _key  <=9) then {
			private _ctrl_questions = _display getvariable ["pr0_dialogue_question_list" ,[]];
			private _answers_total = 0;
			{
				private _ctrl_question = _x;
				private _answers_ = count (_ctrl_question getVariable ["_answers",[]]);
				if(_key<=_answers_)exitWith{
					_ctrl_question setVariable ["answer_index", _key-1-_answers_total];
				};
				_answers_total = _answers_total + _answers_;
			}forEach _ctrl_questions;
			true;//disable default key events (commanding menu)
		}else{
			false;
		};   
	}];
	_display setVariable ["pr0_dialogue_keyDownEvent",_keyDownEvent];
};



//-----------------------------------------------------------
//					wait until its clicked 					|
//-----------------------------------------------------------

//wait untill we get an answer
private _selected_index = -1;
private _waiting_since = time; 
waitUntil {
	sleep 0.1;
	_selected_index = _ctrl_question getVariable ["answer_index",-1];
	
	if(_speaker distance player > FLOAT_MAX_LEAVING_DISTANCE)then{_selected_index = -TYPE_EVENT_WALKED_AWAY};

	//we need to check this on server anyway so no need to do it here 
	//if(time > _waiting_since + FLOAT_MAX_WAIT_FOR_ANSWER)then{_selected_index = -TYPE_EVENT_OUT_OF_TIME}; 

	if(
		!alive player || player getVariable ["ace_isunconscious",false] || 
		!alive _speaker || _speaker getVariable ["ace_isunconscious",false] 
	)then{_selected_index = -TYPE_EVENT_DEATH};

	_selected_index != -1;
};


//Remove answers from question sentence
_ctrl_question setVariable ["_answers",[]];
[_ctrl_question] call pr0_fnc_dialogue_updateSentence;

//remove question from question list so its not being used anymore
private _ctrl_questions = _display getvariable ["pr0_dialogue_question_list" ,[]];
_ctrl_questions pushBack _ctrl_question;
_display setvariable ["pr0_dialogue_question_list" ,_ctrl_questions];

//update all questions (renumber answers and remove answers from the question that has been answered)
{_x  call pr0_fnc_dialogue_updateSentence;}foreach _ctrl_questions;

//change type so it can be removed
_ctrl_question setVariable ["_type", TYPE_SENTENCE];

//send answer to server
player setVariable ["pr0_dialogue_answer_index",[],true];

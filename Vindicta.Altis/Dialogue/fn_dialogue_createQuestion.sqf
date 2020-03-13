#include "defineCommon.inc"


params [["_owner",0,[0]],["_question_event_id",-1,[0]],["_speaker",objNull,[objNull]],["_text","",[""]],["_loudness",1,[0]],["_answers",[],[[]]]];

disableSerialization;
private _display = findDisplay 46;

//Create sentence with answers for player
private _ctrl_question = [_speaker,_text,_loudness,_answers] call pr0_fnc_dialogue_createSentence;

_ctrl_question setVariable ["_owner",_owner];
_ctrl_question setVariable ["_question_event_id",_question_event_id];

//add question to list
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

			{
				scopeName "loop_questions";
				private _ctrl_question = _x;
				private _answers = _ctrl_question getVariable ["_answers",[]];
				{
					private _answer_nr = _x#INDEX_ANSWER_NR;

					private _answer_index = _foreachIndex;
					if(_key == _answer_nr)exitWith{
						//answer found 

						//inform server about answer
						private _question_event_id = _ctrl_question getVariable ["_question_event_id",-1];
						private _owner = _ctrl_question getVariable ["_owner", 2];
						
						[STRING_QUESTION_RETURN_EVENT, [_question_event_id, _answer_index], _owner] call CBA_fnc_ownerEvent;

						//remove answers from question 
						_ctrl_question call pr0_fnc_dialogue_deleteQuestion;

						breakOut "loop_questions";
					};

				}forEach _answers;
			}forEach _ctrl_questions;
			true;//disable default key events (commanding menu)
		}else{
			false;
		};   
	}];
	_display setVariable ["pr0_dialogue_keyDownEvent",_keyDownEvent];
};


//create check condition in case player walks away or someone gets killed
[
	{
		params ["_speaker","_ctrl_question","_question_event_id","_owner"];
		
		private _event_index = 	if(
			(!alive player || {player getVariable ["ace_isunconscious",false]}) ||
			{!alive _speaker || {_speaker getVariable ["ace_isunconscious",false]}} //alive returns false on objNull
		)then{
			TYPE_EVENT_DEATH;
		}else{
			if(player distance _speaker > FLOAT_MAX_LEAVING_DISTANCE_QUESTION)exitWith{
				TYPE_EVENT_WALKED_AWAY
			};
			-1;
		};
		
		if(_event_index == -1)exitWith{false;};

		//inform server
		[STRING_QUESTION_RETURN_EVENT, [_question_event_id,_event_index-666],_owner] call CBA_fnc_ownerEvent;// event and answer can be 0

		//remove answers from question 
		[_ctrl_question] call pr0_fnc_dialogue_deleteQuestion;
		true;
	},//condition
	{},//code that runs when condition is met
	[_speaker,_ctrl_question,_question_event_id,_owner],//args
	FLOAT_MAX_WAIT_FOR_ANSWER,//time out
	{
		params ["_speaker","_ctrl_question","_question_event_id","_owner"];


		//check if question was already removed
		private _answers = _ctrl_question getVariable ["_answers",[]];
		if(count _answers == 0)exitWith{};

		//inform server
		[STRING_QUESTION_RETURN_EVENT, [_question_event_id,TYPE_EVENT_OUT_OF_TIME-666],_owner] call CBA_fnc_ownerEvent;// event and answer can be 0

		//remove answers from question 
		[_ctrl_question] call pr0_fnc_dialogue_deleteQuestion;
	}//code that runs after time out
] call CBA_fnc_waitUntilAndExecute;

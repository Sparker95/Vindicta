#include "defineCommon.inc"

disableSerialization;
private _display = findDisplay 46;

params [["_ctrl_question",controlNull,[controlNull]]];

//remove question from question list so its not being used anymore
private _ctrl_questions = _display getvariable ["pr0_dialogue_question_list" ,[]];
_ctrl_questions - [_ctrl_question];
_display setvariable ["pr0_dialogue_question_list" ,_ctrl_questions];

//Remove answers from question sentence
_ctrl_question setVariable ["_answers",[]];


//renumber answers on other questions and remove answers from this question
{_x  call pr0_fnc_dialogue_updateSentence;}foreach _ctrl_questions;

//change type so it can be removed
_ctrl_question setVariable ["_type", TYPE_SENTENCE];
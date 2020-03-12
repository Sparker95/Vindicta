#include "defineCommon.inc"


params [["_question_event_id",-1,[0]],["_answer_index",0,[0]]];

private _namespaces = missionNamespace getVariable ["dialog_nameSpaces",[]];
{
	if(_x getVariable ["_question_event_id",-1] == _question_event_id)exitWith{
		private _namespace = _x;
		private _events = _namespace getVariable ["_events",[]];

		[STRING_QUESTION_RETURN_EVENT, _question_event_id] call CBA_fnc_removeEventHandler;
		_namespace setVariable ["_question_event_id",nil];

		//check if answer was given or event happent
		private _answer_or_event = ["#end",{},[]];
		if(_answer_index < 0)then{
			_answer_or_event = _events#(_answer_index+666);//we subtracted 666 before to make it smaller then 0
		}else{
			private _answers = _namespace getVariable ["_answers",[]];
			_answer_or_event = _answers#_answer_index;
		};

		_events set [TYPE_EVENT_JUMP_TO, _answer_or_event];
		_namespace setVariable ["_events",_events];

		_namespace call pr0_fnc_dialogue_mainLoop;

	};
}forEach _namespaces;



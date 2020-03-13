#include "defineCommon.inc"


params [["_question_event_id",-1,[0]],["_answer_index",0,[0]]];

private _namespaces = missionNamespace getVariable ["dialog_nameSpaces",[]];
{
	if(_x getVariable ["_question_event_id",-1] == _question_event_id)exitWith{
		private _namespace = _x;

		[STRING_QUESTION_RETURN_EVENT, _question_event_id] call CBA_fnc_removeEventHandler;
		_namespace setVariable ["_question_event_id",nil];

		//check if answer was given or event happent
		if(_answer_index < 0)then{
			private _event_index = (_answer_index+666);//we subtracted 666 before to make it smaller then 0
			[_namespace,_event_index] call pr0_fnc_dialogue_mainLoop_end;
		}else{
			private _answers = _namespace getVariable ["_answers",[]];
			[_namespace,(_answers#_answer_index)] call pr0_fnc_dialogue_mainLoop;
		};
	};
}forEach _namespaces;



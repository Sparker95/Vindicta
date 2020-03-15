#include "defineCommon.inc"


params["_namespace"];

private _unit_1 = _namespace getVariable ["_unit_1",objNull];
private _unit_2 = _namespace getVariable ["_unit_2",objNull];
private _events = _namespace getVariable ["_events",""];
private _question = _namespace getVariable ["_question",[]];
private _answers = _namespace getVariable ["_answers",[]];
private _conversation_args = _namespace getVariable ["_conversation_args",[]];

//run optional code if it was given
[_unit_1,_unit_2,_conversation_args,(_question#INDEX_SENTENCE_ARGS)] call (_question#INDEX_SENTENCE_SCRIPT);

private _text = _question#INDEX_SENTENCE_TEXT;
private _speaker = _question#INDEX_SENTENCE_SPEAKER;
private _listener = _question#INDEX_SENTENCE_LISTENER;
private _loudness = _question#INDEX_SENTENCE_LOUDNESS;
private _silence = _question#INDEX_SENTENCE_SILENCE;

if(!_silence)then{
	//show the question to all players except listener.
	//listener needs dialogue with options
	{
		if(_x distance _speaker < (FLOAT_MAX_LISTENING_DISTANCE * _loudness))then{
			[_speaker, _text,_loudness] remoteExecCall ["pr0_fnc_dialogue_createSentence",_x];
		};
	}forEach (Allplayers - entities "HeadlessClient_F" - [_listener]);
};

if(_listener in Allplayers)then{
	//every question has its own event handler, who cares it might be a few at the same time max
	private _question_event_id = [STRING_QUESTION_RETURN_EVENT, pr0_fnc_dialogue_mainLoop_question_return] call CBA_fnc_addEventHandler;
	_namespace setVariable ["_question_event_id",_question_event_id];

	//create question for client
	[clientOwner,_question_event_id,_speaker,_text,_loudness,_answers] remoteExecCall ["pr0_fnc_dialogue_createQuestion",_listener];
	
	//incase player disconnects or something breaks
	[{
		params ["_namespace","_question_event_id"];
		if!(isnull _namespace)then{
			private _new_question_event_id = _namespace getVariable ["_question_event_id",_question_event_id];
			if(_question_event_id == _new_question_event_id)then{
				[STRING_QUESTION_RETURN_EVENT, [_question_event_id,TYPE_EVENT_OUT_OF_TIME-666]] call CBA_fnc_localEvent;
			};
		};
	}, [_namespace,_question_event_id], FLOAT_MAX_WAIT_FOR_ANSWER+5] call CBA_fnc_waitAndExecute;

}else{
	//question asked to a AI
	private _answer_ai = _namespace getVariable "_answer_ai";

	//answer have been said now we need to wait for the next thing to happen
	private _delay=  FLOAT_SPEACH_TIME(_answer_ai#INDEX_SENTENCE_TEXT) + 0.5;

	//continue to next node
	[pr0_fnc_dialogue_mainLoop, [_namespace,_answer_ai], _delay] call CBA_fnc_waitAndExecute;

};


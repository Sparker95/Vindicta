#include "defineCommon.inc"


params["_namespace"];


private _unit_1 = _namespace getVariable ["_unit_1",objNull];
private _unit_2 = _namespace getVariable ["_unit_2",objNull];
private _events = _namespace getVariable ["_events",""];
private _sentences = _namespace getVariable ["_sentences",[]];
private _conversation_args = _namespace getVariable ["_conversation_args",[]];

//check if units are alive and close to each other
private _endCondition = [_unit_1,_unit_2] call pr0_fnc_dialogue_mainLoop_checkConditions;
if(_endCondition != -1)exitWith{
	_events set [TYPE_EVENT_JUMP_TO, _events#_endCondition];
	_namespace setVariable ["_events",_events];
	_namespace call pr0_fnc_dialogue_mainLoop;
}; 

diag_log str ["sentence", _sentences];

private _sentence = _sentences#0;
_sentences deleteAt 0;
_namespace setVariable ["_sentences",_sentences];

//run optional code if it was given
[_unit_1,_unit_2,_conversation_args,(_sentence#INDEX_SENTENCE_ARGS)] call (_sentence#INDEX_SENTENCE_SCRIPT);
		
//Check if sentences is a hint or silince sentence
private _text = _sentence#INDEX_SENTENCE_TEXT;
private _speaker = _sentence#INDEX_SENTENCE_SPEAKER;
private _listener = _sentence#INDEX_SENTENCE_LISTENER;
private _loudness = _sentence#INDEX_SENTENCE_LOUDNESS;
private _silence = _sentence#INDEX_SENTENCE_SILENCE;
if(_silence)then{
	//show sentence to the ones who are having the conversation
	if(_speaker in Allplayers)then{
		[_speaker, _text, _loudness] remoteExecCall [pr0_fnc_dialogue_createSentence,_speaker];
	};
	if(_listener in Allplayers)then{
		[_speaker, _text, _loudness] remoteExecCall [pr0_fnc_dialogue_createSentence,_listener];
	};
}else{
	//show sentence to everone who is nearby
	[_speaker,_text,_loudness] call pr0_fnc_dialogue_createSimple;
};

//call next sentence if any are left
if(count _sentences>0)exitWith{
	private _delay=  FLOAT_SPEACH_TIME(_sentence#INDEX_SENTENCE_TEXT) + 0.5;
	[pr0_fnc_dialogue_mainLoop_sentence, _namespace, _delay] call CBA_fnc_waitAndExecute;
};

//check if there is a question
private _question = _namespace getVariable ["_question",[]];
if(count _question>0)exitWith{
	private _delay = FLOAT_SPEACH_TIME(_question#INDEX_SENTENCE_TEXT) + 0.5;
	[pr0_fnc_dialogue_mainLoop_question, _namespace, _delay] call CBA_fnc_waitAndExecute;
};

//continue to next node
_namespace call pr0_fnc_dialogue_mainLoop


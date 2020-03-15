#include "defineCommon.inc"


params["_namespace"];

private _unit_1 = _namespace getVariable "_unit_1";
private _unit_2 = _namespace getVariable "_unit_2";
private _events = _namespace getVariable "_events";
private _sentences = _namespace getVariable "_sentences";
private _conversation_args = _namespace getVariable "_conversation_args";

//check if units are alive and close to each other
private _endCondition = if(
	(!alive _unit_1 || {_unit_1 getVariable ["ace_isunconscious",false]}) ||
	{!alive _unit_2 || {_unit_2 getVariable ["ace_isunconscious",false]}} //alive returns false on objNull
)then{
	TYPE_EVENT_DEATH;
}else{
	if(_unit_1 distance _unit_2 > FLOAT_MAX_LEAVING_DISTANCE)then{
		TYPE_EVENT_WALKED_AWAY
	}else{
		-1;
	};
};

if(_endCondition != -1)exitWith{
	[_namespace,_endCondition] call pr0_fnc_dialogue_mainLoop_end;
}; 

//get current sentence and remove it from the list
private _sentence = _sentences#0;
_sentences deleteAt 0;

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

//sentence have been said now we need to wait for the next thing to happen
private _delay=  FLOAT_SPEACH_TIME(_sentence#INDEX_SENTENCE_TEXT) + 0.5;

//call next sentence if any are left
if(count _sentences>0)exitWith{
	[pr0_fnc_dialogue_mainLoop_sentence, _namespace, _delay] call CBA_fnc_waitAndExecute;
};

//check if there is a question
private _question = _namespace getVariable "_question";
if(count _question>0)exitWith{
	[pr0_fnc_dialogue_mainLoop_question, _namespace, _delay] call CBA_fnc_waitAndExecute;
};

//continue to next node
private _jump_to = _namespace getVariable "_jump_to";
[pr0_fnc_dialogue_mainLoop, [_namespace,_jump_to], _delay] call CBA_fnc_waitAndExecute;


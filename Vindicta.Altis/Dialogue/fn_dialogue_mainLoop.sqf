#include "defineCommon.inc"


params ["_namespace","_jump_to_new"];

scopeName "mainloop";

private _dialogueSets = _namespace getVariable ["_dialogueSets",[]];
private _unit_1 = _namespace getVariable ["_unit_1",objNull];
private _unit_2 = _namespace getVariable ["_unit_2",objNull];
private _conversation_args = _namespace getVariable ["_conversation_args",[]];
private _default_events = _namespace getVariable ["_default_events",[]];
private _end_scripts = _namespace getVariable ["_end_scripts",[]];


//this array countains the new node_id, and the script and args from the previouse answer/jump_to action
_jump_to_new params [["_node_id","",[""]],["_previous_script",{},[{}]],["_previous_arg",[]]];

//used only for error message
_namespace setVariable ["_node_id",_node_id];

//run code from previouse node
_previous_arg call _previous_script;

diag_log str ["main",_node_id];
if(_node_id isEqualTo "#end")exitWith{
	_namespace call pr0_fnc_dialogue_mainLoop_end;
};

if(_node_id isEqualTo "")exitWith{
	[_namespace,"no node_id given"] call pr0_fnc_dialogue_mainLoop_error;
};

//-----------------------------------------------------------
//				Find all nodes with same id					|
//-----------------------------------------------------------

//find all nodes with given node_id. This can be more then one when multiple dialogue arrays have been given
private _node_arrays = [];
{	
	private _dialogueSet = _x;
	{
		_x params [["_node_id_x",""]];
		
		scopeName "_dialogueSet";

		//check if this is a node or a default event.
		//if its an event we are not intressed and skip it
		if(_node_id_x isEqualType "")then{
			_x params ["",["_node_type",TYPE_CREATE,[TYPE_CREATE,{}]],["_script",{},[{}]]];

			//no node type was given so the script is on the node type position.
			//lets move it end set default node type
			if(_node_type isEqualType {})then{
				_script = _node_type;
				_node_type = TYPE_CREATE;
			};

			if (tolower _node_id_x isEqualTo tolower _node_id)exitWith{
				
				private _action_array = [_unit_1, _unit_2, _conversation_args] call _script;

				if(isNil "_action_array" || {!(_action_array isEqualType [])})then{
					[_namespace,"node didnt return array"] call pr0_fnc_dialogue_mainLoop_error;
					breakOut "main";
				}else{
					_node_arrays pushBack [_node_type, _action_array];
				};
				
				// we found the node in this data set, so we can move to the next one
				breakOut "_dialogueSet";
			};
		};
	}forEach _dialogueSet;
}forEach _dialogueSets;

if(count _node_arrays == 0)exitWith{
	[_namespace,"node(s) is/are empty"] call pr0_fnc_dialogue_mainLoop_error;
	breakOut "main";
};

//we can skip if it if it will be overwriten
private _overwrite_found = 0;
{
	_x params ["_node_type"];
	if(_node_type in [TYPE_OVERWRITE,TYPE_CREATE])then{
		if(_node_type == TYPE_OVERWRITE && _forEachIndex == 0)then{
			[_namespace,"node type is TYPE_OVERWRITE but nothing was overwriten"] call pr0_fnc_dialogue_mainLoop_error;
			breakOut "main";
		};
		_overwrite_found = _forEachIndex;
	};
}forEach _node_arrays;

//-----------------------------------------------------------
//				Format conversation into arrays				|
//-----------------------------------------------------------

private _sentences = [];
private _question = [];
private _answers = [];
private _answer_ai = ["#end",{},[]];
private _jump_to = ["#end",{},[]];
private _events = +_default_events;//we dont want to overwrite the default events
private _end_scripts_new = [];

//loop the nodes
for "_i" from _overwrite_found to count _node_arrays -1 do{
	(_node_arrays#_i) params ["_node_type","_action_array"];
	
	//loop the node and fill the arrays defined above
	{
		_x params [["_type",-1,[0]]];
		_x deleteAt 0;//remove _type because we declared it above and we dont need it in the array

		if(_node_type == TYPE_INHERIT && !(_type in INHERIT_TYPES))exitWith{
			[_namespace, format["inheritence not supported for node_type: %1" ,_node_type]] call pr0_fnc_dialogue_mainLoop_error;
			breakOut "main";
		};

		private _silence = _type in SILENCE_TYPES;
		//diag_log str [_node_type, _type, _x];
		switch (_type) do {
			case TYPE_SENTENCE;
			case TYPE_SENTENCE_SILENECE;
			case TYPE_QUESTION;
			case TYPE_QUESTION_SILENECE:{
				_x params [
					["_text","",["",[]]], 
					["_int_speaker",0,[0]],
					["_loudness",1,[0]],
					["_script",{},[{}]],
					["_args",[]]
				];
				

				if!(_int_speaker in [1,2])exitWith{
					[_namespace,"wrong speaker nr given"] call pr0_fnc_dialogue_mainLoop_error;
					breakOut "main";
				};

				private _speaker = [_unit_1, _unit_2] select (_int_speaker-1);
				private _listener = [_unit_2, _unit_1] select (_int_speaker-1);

				
				if(_text isEqualType [])then{_text = selectRandom _text};
				
				if(_type in [TYPE_SENTENCE_SILENECE,TYPE_SENTENCE])then{
					_sentences pushBack [_text,_silence,_speaker,_listener,_loudness,_script,_args];
				}else{
					_question = [_text,_silence,_speaker,_listener,_loudness,_script,_args];
				};
				
			};
			case TYPE_ANSWER:{
				_x params [
					["_text","",[""]],
					["_jump","",["",[]]],
					["_script",{},[{}]],
					["_args",[]]
				];
				_answers pushBack [_jump,_script,_args,_text];//same structure as event
			};
			case TYPE_REMOVE_ANSWER:{
				_x params [["_jump","",[""]]];
				private _a = (count _answers -1);
				for "_i" from _a to 0 step -1do{
					private _answer = (_answers#_i);
					private _jump_i = _answer#INDEX_ANSWER_SCRIPT;
					if(_jump isEqualto _jump_i)then{_answers deleteAt _i}
				};
			};
			case TYPE_JUMP_TO: {
				_x params [
					["_jump","",["",[]]],
					["_script",{},[{}]],
					["_args",[]]
				];
				_jump_to = [_jump,_script,_args];
			};
			case TYPE_ANSWER_AI: {
				_x params [
					["_jump","",["",[]]],
					["_script",{},[{}]],
					["_args",[]]
				];
				_answer_ai = [_jump,_script,_args];
			};
			case TYPE_ON_WALKED_AWAY;
			case TYPE_ON_OUT_OF_TIME;
			case TYPE_ON_DEATH;
			case TYPE_ON_UNEXPECTED_END: {
				_x params [
					["_script",{},[{}]],
					["_args",[]]
				];
				
				private _event_type = [TYPE_EVENT_WALKED_AWAY,TYPE_EVENT_OUT_OF_TIME,
									TYPE_EVENT_DEATH,TYPE_EVENT_UNEXPECTED_END] #
									([TYPE_ON_WALKED_AWAY,TYPE_ON_OUT_OF_TIME,
									TYPE_ON_DEATH,TYPE_ON_UNEXPECTED_END] find _type);

				_events set [_event_type,[_script,_args]];
			};
			case TYPE_ON_END: {
				_x params [
					["_script",{},[{}]],
					["_args",[]]
				];
				if!(_script isEqualTo {})then{
					_end_scripts_new pushBack [_script,_args];
				};
				
			};
			case TYPE_ON_END_OVERWRITE: {
				if!(_node_type isEqualto TYPE_INHERIT)then{
					[_namespace,"TYPE_ON_END_OVERWRITE found but node_type != TYPE_INHERIT"] call pr0_fnc_dialogue_mainLoop_error;
					breakOut "main";
				};

				_x params [
					["_script",{},[{}]],
					["_args",[]]
				];
				_end_scripts_new = [[_script,_args]];//reset array and add new found end_script
			};
			default {
				[_namespace,"undefined type"] call pr0_fnc_dialogue_mainLoop_error;
				breakOut "main";
			};
		};
	}forEach _action_array;

}; 


//add new endscript to list
if(count _end_scripts_new != 0)then{_end_scripts append _end_scripts_new;};

//overwrite old variables
_namespace setVariable ["_sentences",_sentences];
_namespace setVariable ["_question",_question];
_namespace setVariable ["_answers",_answers];
_namespace setVariable ["_answer_ai",_answer_ai];
_namespace setVariable ["_jump_to",_jump_to];
_namespace setVariable ["_events",_events];


//we need to do this after because we need an updated _namespace
if(count _sentences > 0)exitWith{_namespace call pr0_fnc_dialogue_mainLoop_sentence;};

//If node contains both sentence and question sentence will be called first.
//Afterwards pr0_fnc_dialogue_mainLoop_sentence calls pr0_fnc_dialogue_mainLoop_question
if(count _question > 0)exitWith{_namespace call pr0_fnc_dialogue_mainLoop_question;};

//node without sentence or question was given
[_namespace,TYPE_EVENT_ERROR] call pr0_fnc_dialogue_mainLoop_end;


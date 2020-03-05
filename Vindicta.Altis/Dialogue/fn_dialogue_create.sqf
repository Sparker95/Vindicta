#include "defineCommon.inc"

/*
    By: Jeroen Notenbomer

    Create dialogue based on given conversation ID.
	Check out https://github.com/Sparker95/Vindicta/wiki/Conversation-framework

	Input:
		_unit_1:
		_unit_2(optional): 
		_node_id: The id of the conversation you want to start
		_script(optional): Code that needs to run at the end of the conversation
		_args(optional): arguments that will be feed to all scripts 
	Output:
		nil
*/

//we need to sleep a lot
_this spawn {

params[
	["_unit_1",objNull,[objNull]],
	["_unit_2",objNull,[objNull]],//optional
	["_node_id","",[""]],
	["_end_script",{},[{}]],//optional
	["_conversation_args",[],[]]//optional
];

if(isnull _unit_2)then {_unit_2 = _unit_1};
if(isNull _unit_1)exitWith{};

//search for dateSets that are going to be used
private _dataSets_registered = missionNamespace getVariable ["dialogue_dataSets",[]];
private _dataSet_ids_unit = _unit_2 getVariable ["dialogue_dataSet_ids",[]];
private _dataSets = [];
{
	_X params [["_dataSet_id_unit","",[""]]];
	{
		_x params ["_dataSet_id_registered","_dataSet_array"];
		if(tolower _dataSet_id_unit isEqualto tolower _dataSet_id_registered)exitWith{
			_dataSets pushBack _dataSet_array;
		};
	}forEach _dataSets_registered;

}forEach _dataSet_ids_unit;

private _fnc_error = {
	params [["_text","",[""]]];
	diag_log _text;
	BreakTo "while";
};

//we need something from it after the while loop so we need to declare it here
private _events = [];{_events set [_x, ["#end",{},[]]];}forEach EVENT_TYPES;

//main loop for the conversation
scopeName "while";
while{true}do{
		
	//-----------------------------------------------------------
	//				Find all nodes with same id					|
	//-----------------------------------------------------------


	private _noded_arrays = [];
	{	
		private _dataSet = _x;
		{

			_x params [["_node_id_x","",[""]],["_node_type",TYPE_CREATE,[TYPE_CREATE,{}]],["_script",{},[{}]]];

			if (tolower _node_id_x isEqualTo tolower _node_id)exitWith{

				if(_node_type isEqualType {})then{
					_script = _node_type;
					_node_type = TYPE_CREATE;
				};

				private _node_array = [_unit_1, _unit_2, _conversation_args] call _script;
				_noded_arrays pushBack [_node_type, _node_array];
			}
		}forEach _dataSet;
	}forEach _dataSets;

	

	//we can skip if it if it will be overwriten
	private _overwrite_found = 0;
	{
		_x params ["_node_type"];
		if(_node_type in [TYPE_OVERWRITE,TYPE_CREATE])then{
			if(_node_type == TYPE_OVERWRITE && _forEachIndex == 0)then{
				["ERROR NODE TYPE OVERWRITE BUT NOTHING WAS OVERWRITEN: %1",_node_id] call _fnc_error;
			};
			_overwrite_found = _forEachIndex;
		};
	}forEach _noded_arrays;

	//-----------------------------------------------------------
	//				Format conversation into arrays				|
	//-----------------------------------------------------------

	private _sentences = [];
	private _question = [];
	private _answers = [];
	private _answer_ai = ["",{},[]];
	private _new_node_array = ["",{},[]];
	_events = [];{_events set [_x, ["#end",{},[]]];}forEach EVENT_TYPES;
	
	//loop the nodes
	for "_i" from _overwrite_found to count _noded_arrays -1 do{
		(_noded_arrays#_i) params ["_node_type","_node_array"];
		
		//loop the node and fill the arrays defined above
		{
			_x params [["_type",-1,[0]]];
			_x deleteAt 0;//remove _type because we declared it above and we dont need it in the array

			if(_node_type == TYPE_INHERIT && !(_type in INHERIT_TYPES))exitWith{
				format ["ERROR I: %1 TYPE: CAN NOT BE USED WITH INHERITENCE",_node_id,_type] call _fnc_error;
			};

			private _silence = _type == TYPE_SENTENCE_SILENECE;

			switch (_type) do {
				case TYPE_SENTENCE;
				case TYPE_SENTENCE_SILENECE;
				case TYPE_QUESTION;
				case TYPE_QUESTION_SILENECE:{
					_x params [
						["_text","",["",[]]], 
						["_int_talker",0,[0]],
						["_loudness",1,[0]],
						["_script",{},[{}]],
						["_args",[],[]]
					];
					

					if!(_int_talker in [1,2])exitWith{format["ERROR WRONG TALKER NR:%1",_node_id] call _fnc_error;};

					private _speaker = [_unit_1, _unit_2] select (_int_talker-1);
					private _listener = [_unit_2, _unit_1] select (_int_talker-1);

					
					if(_text isEqualType [])then{_text = selectRandom _text};
					
					if(_type in [TYPE_SENTENCE_SILENECE,TYPE_SENTENCE])then{
						_sentences pushBack [_text,_silence,_speaker,_listener,_loudness,_script,_args];
					}else{
						
						if(_listener in allPlayers)then{
							_question = [_text,_silence,_speaker,_listener,_loudness,_script,_args];
						};
					};
					
				};
				case TYPE_ANSWER:{
					_x params [
						["_text","",[""]],
						["_jump","",["",[]]],
						["_script",{},[{}]],
						["_args",[],[]]
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
				case TYPE_JUMP_TO;
				case TYPE_EVENT_WALKED_AWAY;
				case TYPE_EVENT_OUT_OF_TIME;
				case TYPE_EVENT_DEATH;
				case TYPE_EVENT_UNEXPECTED_END;
				case TYPE_EVENT_END: {
					_x params [
						["_jump","",[""]],
						["_script",{},[{}]],
						["_args",[],[]]
					];
					switch _type do{
						case TYPE_JUMP_TO:{_new_node_array = [_jump,_script,_args];};
						case TYPE_ANSWER_AI:{_answer_ai = [_jump,_script,_args];};
						default {_events set [_type,[_jump,_script,_args]];};
					};
					
				};
				default {};
			};
		}forEach _node_array;

	}; 

	//check if conversation is properly structured 
	if((count _sentences + count _question) == 0)exitWith{
		format["ERROR NO SENTENCE OR QUESTION: %1",_node_id]call _fnc_error};

	if(count _question > 0 && count _answers == 0)exitWith{
		format["ERROR NO ANSWERS FOR QUESTION: %1",_node_id]call _fnc_error};

	if(count _question > 0 && {!(_new_node_array#INDEX_EVENT_JUMP isEqualTo "")})exitWith{
		format["ERROR QUESTION AND JUMP GIVEN: %1",_node_id]call _fnc_error};

	if(count _question == 0 && _new_node_array#INDEX_EVENT_JUMP isEqualTo "")exitWith{
		format["ERROR NO QUESTION OR JUMP GIVEN IN: %1",_node_id]call _fnc_error};

	//stop conversation if one unit is dead or unconsious 
	if(
		(!alive _unit_1 || {_unit_1 getVariable ["ace_isunconscious",false]}) ||
		{!alive _unit_2 || {_unit_2 getVariable ["ace_isunconscious",false]}} //alive returns false on objNull
	)exitWith{
		_new_node_id = _events # TYPE_EVENT_DEATH # INDEX_EVENT_JUMP;
		
		//i think we can ignore empty strings
		if(_new_node_id isEqualTo "")then{_new_node_id isEqualTo "#end"};

		//Check if script was given in case of this event
		[_unit_1,_unit_2,_conversation_args,(_events # TYPE_EVENT_DEATH # INDEX_EVENT_ARGS)]
			call (_events # TYPE_EVENT_DEATH # INDEX_EVENT_SCRIPT);
	};


	//stop conversation if moved away to far
	if(_unit_1 distance _unit_2 > FLOAT_MAX_LEAVING_DISTANCE)exitWith{
		_new_node_id = _events # TYPE_EVENT_WALKED_AWAY # INDEX_EVENT_JUMP;
		
		//i think we can ignore empty strings
		if(_new_node_id isEqualTo "")then{_new_node_id isEqualTo "#end"};

		//Check if script was given in case of this event
		[_unit_1,_unit_2,_conversation_args,(_events # TYPE_EVENT_WALKED_AWAY # INDEX_EVENT_ARGS)]
			call (_events # TYPE_EVENT_WALKED_AWAY # INDEX_EVENT_SCRIPT);
	};


	//-----------------------------------------------------------
	//		Loop all sentences and show them on screen			|
	//-----------------------------------------------------------

	{
		
		//run optional code if it was given
		[_unit_1,_unit_2,_conversation_args,(_x#INDEX_SENTENCE_ARGS)] call (_x#INDEX_SENTENCE_SCRIPT);
		
		//Check if sentences is a hint or silince sentence
		private _text = _x#INDEX_SENTENCE_TEXT;
		private _speaker = _x#INDEX_SENTENCE_SPEAKER;
		private _listener = _x#INDEX_SENTENCE_LISTENER;
		private _loudness = _x#INDEX_SENTENCE_LOUDNESS;
		private _silence = _x#INDEX_SENTENCE_SILENCE;
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
		sleep ((count (_x#INDEX_SENTENCE_TEXT))/12 + 0.5);
	}foreach _sentences;

	//-----------------------------------------------------------
	//				Create Question if there is one				|
	//-----------------------------------------------------------

	if(count _question > 0)then{
		
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
			
			//TODO multiquestion support here

			//create question for client
			[_speaker,_text,_loudness,_answers] remoteExec ["pr0_fnc_dialogue_createQuestion",_listener];

			//wait for answer from player
			_listener setVariable ["pr0_dialogue_answer_index",[]];
			waitUntil{
				sleep 0.1;
				!(_listener getVariable ["pr0_dialogue_answer_index", []] isEqualto []);
			};
			_answer_index = _listener getVariable ["pr0_dialogue_answer_index", []];
			
			//No answer given for some reason.
			if(_answer_index < 0)exitWith{
				_new_node_array = _events # -_answer_index;
			};

			//what did we answer?
			private _answer = _answers#(_answer_index);

			//update conversation_id
			_new_node_array = _answer;

		}else{
			//question asked to a AI
			_new_node_array = _answer_ai;
		};
		
	};// end if question

	//run optional script
	private _args = [_unit_1, _unit_2, _conversation_args,_new_node_array#INDEX_EVENT_ARGS];
	_args call (_new_node_array#INDEX_EVENT_SCRIPT);

	_new_node_id = _new_node_array#INDEX_EVENT_JUMP;
	if(_new_node_array isEqualTo "")exitWith{
		format["ERROR NO NEW NODE ID GIVEN FOR: %1",_node_id]call _fnc_error;
	};
	if(_new_node_id isEqualTo "#end")exitWith{};
	
	//valid new conversation found. Loop back and do everything again!
	_node_id = _new_node_id;
	
};//end while

//execute optional code
private _args = [_unit_1, _unit_2, _conversation_args];
_args call (_events#TYPE_EVENT_END#INDEX_EVENT_SCRIPT);
_args call _end_script;


};//spawn
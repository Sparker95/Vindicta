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
	["_unit_2",objNull,[objNull]],
	["_node_id","",[""]],
	["_end_script",{},[{}]],//optional
	["_conversation_args",[],[]]//optional
];

//run code on player if possible
if(!(_unit_1 isEqualTo player) && {_unit_1 in Allplayers}) exitWith{
	_this remoteExec ["pr0_fnc_dialogue_createConversation",_unit_1];
};

if(isnull _unit_2)then {_unit_2 = _unit_1};

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
	private _options = [];
	private _new_node_array = ["#end",{},[]];
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

			switch (_type) do {
				case TYPE_SENTENCE_SILENECE;
				case TYPE_SENTENCE:{
					_x params [
						["_text","",["",[]]], 
						["_int_talker",0,[0]],
						["_script",{},[{}]],
						["_args",[],[]]
					];
					private _silence = _type == TYPE_SENTENCE_SILENECE;

					if!(_int_talker in [1,2])exitWith{
						format["ERROR WRONG TALKER NR:%1",_node_id] call _fnc_error;
					};
					_sentences pushBack [_text,_silence,_int_talker,_script,_args];
				};
				case TYPE_QUESTION_SILENECE;
				case TYPE_QUESTION: {
					_x params [
						["_text","",["",[]]],
						["_script",{},[{}]],
						["_args",[],[]]
					];
					private _silence = _type == TYPE_QUESTION_SILENECE;
					_question = [_text,_silence,_script,_args];
				};
				case TYPE_OPTION_SILENECE;
				case TYPE_OPTION:   {
					_x params [
						["_text","",["",[]]],
						["_jump","",[""]],
						["_spoke_text","",["",[]]],
						["_script",{},[{}]],
						["_args",[],[]]
					];
					private _silence = _type == TYPE_OPTION_SILENECE;
					if(_spoke_text isEqualType "")then{_spoke_text = _text};
					_options pushBack [_text,_silence,_jump,_spoke_text,_script,_args];
				};
				case TYPE_REMOVE_OPTION:{
					_x params [["_jump","",[""]]];
					private _a = (count _options -1);
					for "_i" from _a to 0 do{
						(_options#_i) params [
							["_text_i","",["",[]]],
							["_jump_i","",[""]]
						];
						if(_jump isEqualto _jump_i)then{_options deleteAt _i}
					};
				};
				case TYPE_JUMP_TO: {
					_x params [
						["_jump","",[""]],
						["_script",{},[{}]],
						["_args",[],[]]
					];
					_new_node_array = [_jump,_script,_args];
				};
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
					_events set [_type,[_jump,_script,_args]];
				};
				default {};
			};
		}forEach _node_array;

	}; 

	private _new_node_id = _new_node_array#INDEX_NEW_NODE_JUMP;

	//check if conversation is properly structured 
	if((count _sentences + count _question) == 0)exitWith{
		format["ERROR NO SENTENCE OR QUESTION: %1",_node_id]call _fnc_error};
	if(count _question > 0 && count _options == 0)exitWith{
		format["ERROR NO OPTIONS FOR QUESTION: %1",_node_id]call _fnc_error};
	if(count _question > 0 && {!(_new_node_id isEqualTo "#end")})exitWith{
		format["ERROR QUESTION AND JUMP GIVEN: %1",_node_id]call _fnc_error};
	if(_new_node_id isEqualTo "" && count _question == 0)exitWith{
		format["ERROR NO QUESTION OR JUMP GIVEN IN: %1",_node_id]call _fnc_error};
	if(count _question > 0 && {!(_unit_1 isequalto player)})exitWith{
		format["ERROR QUESTION AND NO PLAYER: %1",_node_id]call _fnc_error};


	//select random sentence if array was given
	{
		if(_x#INDEX_SENTENCE_TEXT isEqualType [])then{
			_x set [INDEX_SENTENCE_TEXT, selectRandom (_x#INDEX_SENTENCE_TEXT)];
		};
	}forEach _sentences;
	{
		if(_x#INDEX_OPTION_TEXT isEqualType [])then{
			_x set [INDEX_OPTION_TEXT, selectRandom (_x#INDEX_OPTION_TEXT)];
		};
		if(_x#INDEX_OPTION_FULL_TEXT isEqualType [])then{
			_x set [INDEX_OPTION_FULL_TEXT, selectRandom (_x#INDEX_OPTION_FULL_TEXT)];
		};
	}forEach _options;
	if(_question#INDEX_QUESTION_TEXT isEqualType [])then{
		_question set [INDEX_QUESTION_TEXT, selectRandom _question#INDEX_QUESTION_TEXT]
	};


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
		private _text = (_x#INDEX_SENTENCE_TEXT);

		if(_x#INDEX_SENTENCE_SILENCE)then{
			//show sentence only to player
			[_unit_1, _unit_2, _text] call pr0_fnc_dialogue_createSentence;
		}else{
			//show sentence to everone who is nearby
			private _speaker = [_unit_1,_unit_2] select ((_x#INDEX_SENTENCE_SPEAKER_NR)-1);
			private _listener = [_unit_2,_unit_1] select ((_x#INDEX_SENTENCE_SPEAKER_NR)-1);
			{
				if(_x distance _speaker < FLOAT_MAX_LISTENING_DISTANCE)then{
					
					[_speaker, _listener, _text] remoteExecCall ["pr0_fnc_dialogue_createSentence",_x];
				};
			}forEach (Allplayers - entities "HeadlessClient_F");
		};
		sleep ((count (_x#INDEX_SENTENCE_TEXT))/12 + 0.5);
	}foreach _sentences;



	//-----------------------------------------------------------
	//				Create Question if there is one				|
	//-----------------------------------------------------------

	if(count _question > 0)then{
	
		disableSerialization;
		private _display = findDisplay 46;

		private _speaker = _unit_2;
		private _listener = player;
		
		[_unit_1,_unit_2,_conversation_args,(_question#INDEX_QUESTION_ARGS)] call (_question#INDEX_QUESTION_SCRIPT);

		if(_question#INDEX_QUESTION_SILENCE)then{
			//show the question to all players except player.
			{
				if(_x distance _speaker < FLOAT_MAX_LEAVING_QUESTION_DISTANCE)then{
					[_speaker, _listener, _question#INDEX_QUESTION_TEXT] remoteExecCall ["pr0_fnc_dialogue_createSentence",_x];
				};
			}forEach (Allplayers - entities "HeadlessClient_F" - [player]);
		};

		//Create sentence with answers for player
		private _ctrl_question = [_speaker,_listener,_question#INDEX_QUESTION_TEXT,_options] call pr0_fnc_dialogue_createSentence;
		
		private _ctrl_questions = _display getvariable ["pr0_dialogue_question_list" ,[]];
		_ctrl_questions pushBack _ctrl_question;
		_display setvariable ["pr0_dialogue_question_list" ,_ctrl_questions];
		
		
		//-----------------------------------------------------------
		//		Create keyevent and wait until its clicked			|
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
						private _answers_ = count (_ctrl_question getVariable ["_options",[]]);
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

		//wait untill we get an answer
		private _selected_index = -1;
		private _waiting_since = time; 
		waitUntil {
			sleep 0.1;
			_selected_index = _ctrl_question getVariable ["answer_index",-1];
			
			if(_unit_1 distance _unit_2 > 10)then{_selected_index = -TYPE_EVENT_WALKED_AWAY};
			if(time > _waiting_since + FLOAT_MAX_WAIT_FOR_ANSWER)then{_selected_index = -TYPE_EVENT_OUT_OF_TIME};
			if(
				!alive _unit_2 || {
				_unit_2 getVariable ["ace_isunconscious",false] || {
				_unit_2 getVariable ["ace_isunconscious",false] }}
			)then{_selected_index = -TYPE_EVENT_DEATH};
			_selected_index != -1;
		};


		//-----------------------------------------------------------
		//					Check given answer						|
		//-----------------------------------------------------------


		
		//Remove options from question sentence
		_ctrl_question setVariable ["_options",[]];
		[_ctrl_question] call pr0_fnc_dialogue_updateSentence;
		
		//remove question from question list so its not being used anymore
		private _ctrl_questions = _display getvariable ["pr0_dialogue_question_list" ,[]];
		_ctrl_questions pushBack _ctrl_question;
		_display setvariable ["pr0_dialogue_question_list" ,_ctrl_questions];
		
		//update all questions (renumber answers and remove answers from the question that has been answered)
		{_x  call pr0_fnc_dialogue_updateSentence;}foreach _ctrl_questions;
		
		//change type so it can be removed
		_ctrl_question setVariable ["_type", TYPE_SENTENCE];

		//No answer given for some reason.
		if(-_selected_index in EVENT_TYPES)exitWith{
			_new_node_id = _events # -_selected_index # INDEX_EVENT_JUMP;
			
			//i think we can ignore empty strings
			if(_new_node_id isEqualTo "")then{_new_node_id isEqualTo "#end"};

			//Check if script was given in case of this event
			[_unit_1,_unit_2,_conversation_args,(_events # -_selected_index # INDEX_EVENT_ARGS)]
				call (_events # -_selected_index # INDEX_EVENT_SCRIPT);
		};
		
		//what did we answer?
		private _selected_option = _options#(_selected_index);

		//update conversation_id
		_new_node_id = _selected_option#INDEX_OPTION_JUMP;
		([_unit_1, _unit_2]+[_new_node_array#INDEX_NEW_NODE_ARGS]) call _new_node_array#INDEX_NEW_NODE_SCRIPT;

		if(_selected_option#INDEX_OPTION_SILENCE)then{
			[_unit_1, _unit_2, _selected_option#INDEX_OPTION_FULL_TEXT] call "pr0_fnc_dialogue_createSentence";
		}else{
			//let everone know what we have answers!
			{
				if(_x distance _unit_1 < FLOAT_MAX_LISTENING_DISTANCE)then{
					[_unit_1, _unit_2, _selected_option#INDEX_OPTION_FULL_TEXT] remoteExecCall ["pr0_fnc_dialogue_createSentence",_x];
				};
			}forEach (Allplayers - entities "HeadlessClient_F");		
		};

		sleep (count(_selected_option#INDEX_OPTION_FULL_TEXT)/12 + 0.5);
	};// end if question


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
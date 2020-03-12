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

params[
	["_unit_1",objNull,[objNull]],
	["_unit_2",objNull,[objNull]],//optional
	["_node_id","",[""]],
	["_end_script",{},[{}]],//optional
	["_conversation_args",[],[]]//optional
];

diag_log str ["create", _node_id];

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

private _events = [];
_events set [TYPE_EVENT_JUMP_TO,[_node_id,{},[]]];

private _end_scripts = [];
_end_scripts pushBack _end_script;
private _namespace = call CBA_fnc_createNamespace;
_namespace setVariable ["_dataSets",_dataSets];
_namespace setVariable ["_unit_1",_unit_1];
_namespace setVariable ["_unit_2",_unit_2];
_namespace setVariable ["_end_scripts",_end_scripts];
_namespace setVariable ["_events",_events];
_namespace setVariable ["_conversation_args",_conversation_args];

private _namespaces = missionNamespace getVariable ["dialog_nameSpaces",[]];
_namespaces pushBack _namespace;
missionNamespace setVariable ["dialog_nameSpaces",_namespaces];

_namespace call pr0_fnc_dialogue_mainLoop;

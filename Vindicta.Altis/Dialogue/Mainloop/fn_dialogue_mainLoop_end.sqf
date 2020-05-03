#include "defineCommon.inc"


params [["_namespace",locationNull,[locationNull]],["_event_type",-1,[0]]];

private _unit_1 = _namespace getVariable ["_unit_1",objNull];
private _unit_2 = _namespace getVariable ["_unit_2",objNull];

private _end_scripts = _namespace getVariable ["_end_scripts",[]];
private _conversation_args = _namespace getVariable ["_conversation_args",[]];
private _events = _namespace getVariable ["_events",[]];
private _question_event_id = _namespace getVariable ["_question_event_id",-1];

//if event was given run extra script that was given
if(_event_type!=-1)then{
	//every event is unexpected so we also run the end unexpected event.
	{
		(_events#_x) params [["_script",{},[{}]],["_arg",[]]];
		[_unit_1, _unit_2, _conversation_args, _arg] call _script;
	}forEach [_event_type,TYPE_EVENT_UNEXPECTED_END];
};

//run all scripts then where defined as end_script
{
	_x params [["_script",{},[{}]],["_arg",[]]];
	[_unit_1, _unit_2, _conversation_args,_arg] call _script; //execute end code
}forEach _end_scripts;


[STRING_QUESTION_RETURN_EVENT, _question_event_id] call CBA_fnc_removeEventHandler;

_namespace call CBA_fnc_deleteNamespace;
private _namespaces = missionNamespace getVariable ["dialog_nameSpaces",[]];
_namespaces = _namespaces - [locationNull];//namespace was delete so its null
missionNamespace setVariable ["dialog_nameSpaces",_namespaces];

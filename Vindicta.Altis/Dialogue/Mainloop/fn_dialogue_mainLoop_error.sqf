#include "defineCommon.inc"


params [["_namespace",locationNull,[locationNull]],["_text","",[""]]];



private _unit_1 = _namespace getVariable ["_unit_1",objNull];
private _unit_2 = _namespace getVariable ["_unit_2",objNull];
private _node_id = _namespace getVariable ["_node_id","UNKNOWN"];

_text = format ["Error in node:%1, %2",_node_id,_text];
diag_log _text;
[_unit_1,_text] call pr0_fnc_dialogue_createSentence;

[_namespace,TYPE_EVENT_ERROR] call pr0_fnc_dialogue_mainLoop_end;
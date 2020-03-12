#include "defineCommon.inc"


params [["_namespace",locationNull,[locationNull]],["_text","",[""]]];



private _unit_1 = _namespace getVariable ["_unit_1",objNull];
private _unit_2 = _namespace getVariable ["_unit_2",objNull];
private _events = _namespace getVariable ["_events",""];
private _node_id = _namespace getVariable ["_node_id","UNKNOWN"];

_text = format ["Error in node:%1, %2",_node_id,_text];
[_unit_1,_unit_2,_text] call pr0_fnc_dialogue_createSimple;

[_namespace] call pr0_fnc_dialogue_mainLoop_end;
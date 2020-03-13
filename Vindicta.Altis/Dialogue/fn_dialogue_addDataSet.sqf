params[
	["_unit", objNull,[objNull]],
	["_dataSet","",[""]]
];

private _dataSets = _unit getVariable ["dialogue_dataSet_ids",[]];
_dataSets pushBackUnique _dataSet;
[_unit, "dialogue_dataSet_ids", _dataSets] call CBA_fnc_setVarNet;

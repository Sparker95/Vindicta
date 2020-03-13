if!(params [
	["_unit", objNull,[objNull]],
	["_dataSets",[],[[],""]],
	["_unused",nil[nil]]//incase someone writes [_unit,"list1","list2"] instead of [_unit,["list1","list2"]]
])exitWith{};

if(_dataSets isEqualType "")then{_dataSets = [_dataSets]};

[_unit, "dialogue_dataSet_ids", _dataSets] call CBA_fnc_setVarNet;
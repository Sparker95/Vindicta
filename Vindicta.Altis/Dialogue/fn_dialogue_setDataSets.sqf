params [
	["_unit", objNull,[objNull]],
	["_dataSets",[],[[],""]],
	["_unused",nil,[nil]]//incase someone writes [_unit,"list1","list2"] instead of [_unit,["list1","list2"]]
];

if(_dataSets isEqualTo "")then{_dataSets = [_dataSets]};
if!(_unit getVariable ["dialogue_dataSet_ids",[]] isEqualTo _dataSets)then{
	_unit setVariable ["dialogue_dataSet_ids", _dataSets];
};

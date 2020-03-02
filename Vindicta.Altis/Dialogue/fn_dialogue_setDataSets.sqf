params [
	["_unit", objNull,[objNull]],
	["_dataSets",[],[[],""]],
	["_unused","",[""]]//incase someone writes [_unit,"list1","list2"] instead of [_unit,["list1","list2"]]
];

if!(_unused isEqualTo "")then{
	diag_log "ERROR CALLED WITH TO MANY ARGUMENTS";
};

if(_dataSets isEqualType "")then{_dataSets = [_dataSets]};

_unit setVariable ["dialogue_dataSet_ids",_dataSets];


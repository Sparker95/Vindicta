params[
	["_unit", objNull,[objNull]],
	["_dataSet","",[""]]
];

private _dataSets = _unit getVariable ["dialogue_dataSet_ids",[]];
private _count = count _dataSets;
_dataSets pushBackUnique _dataSet;
if(count _dataSets > _count)then{
	_unit setVariable ["dialogue_dataSet_ids",_dataSets,true];
};



params[
	["_unit", objNull,[objNull]],
	["_dialogueSet","",[""]]
];

private _dialogueSets = _unit getVariable ["_dialogueSet",[]];
private _count = count _dialogueSets;
_dialogueSets pushBackUnique _dialogueSet;
if(count _dialogueSets > _count)then{
	_unit setVariable ["_dialogueSet",_dialogueSets,true];
};



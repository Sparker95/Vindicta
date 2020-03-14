params [
	["_unit", objNull,[objNull]],
	["_dialogueSets",[],[[],""]],
	["_unused",nil,[nil]]//incase someone writes [_unit,"list1","list2"] instead of [_unit,["list1","list2"]]
];

if(_dialogueSets isEqualTo "")then{_dialogueSets = [_dialogueSets]};
if!(_unit getVariable ["_dialogueSet",[]] isEqualTo _dialogueSets)then{
	_unit setVariable ["_dialogueSet", _dialogueSets];
};

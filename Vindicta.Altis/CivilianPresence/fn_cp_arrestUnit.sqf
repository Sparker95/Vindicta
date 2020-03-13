params ["_unit", ["_arrest", true, [false]]];


// Sets variable which makes the unit's FSM treat him as arrested
_unit setVariable ["#arrested", _arrest];

if(_arrest)then{
	[_unit,"arrested"] call pr0_fnc_dialogue_addDataSet;
}else{
	[_unit,"arrested"] call pr0_fnc_dialogue_removeDataSet;
};
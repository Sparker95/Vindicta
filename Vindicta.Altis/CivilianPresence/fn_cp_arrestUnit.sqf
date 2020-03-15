params ["_unit", ["_arrest", true, [false]]];


// Sets variable which makes the unit's FSM treat him as arrested
_unit setVariable ["#arrested", _arrest,true];//true so clients can use this variable for dialogues
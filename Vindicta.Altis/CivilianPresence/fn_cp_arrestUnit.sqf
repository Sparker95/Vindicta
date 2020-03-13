// Sets variable which makes the unit's FSM treat him as arrested

params ["_unit", ["_arrest", true, [false]]];
_unit setVariable ["#arrested", _arrest];
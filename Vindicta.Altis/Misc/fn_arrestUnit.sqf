/*
	Function: misc_fnc_arrestUnit

	Immobilize a unit and set a global variable to mark them as a prisoner.

	Parameters:
	0: Unit to be immobilized
	1: Immobilizes unit if true (default), frees unit if false

	Author: Marvis 11.05.2019
*/

params ["_unit", ["_bool", true]];

switch (_bool) do {

	default { 

		systemChat "Arresting unit.";

	};

	case false: {

		systemChat "Freeing unit.";

	};
};
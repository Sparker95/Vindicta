/*
Functions to get data from a medium level script object AI_fnc_manageSpottedEnemies.
*/

AI_fnc_getSpottedEnemies =
{
	params ["_so"]; //script object
	_so getVariable ["AI_spottedEnemies", []]
};

AI_fnc_getRequestedAlertState =
{
	params ["_so"]; //script object
	_so getVariable ["AI_requestedAS", 0]
};
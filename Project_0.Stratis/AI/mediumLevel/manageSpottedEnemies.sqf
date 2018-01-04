/*
Functions to get data from a medium level script object AI_fnc_manageSpottedEnemies.
*/

AI_fnc_getReportedEnemies =
{
	params ["_so"]; //script object
	//Wait until the arrays have been released (see manageSpottedEnemies.sqf)
	waitUntil {(_scriptObject getVariable ["AI_reportArraysMutex", 0]) == 0};
	//Lock the mutex
	_scriptObject setVariable ["AI_reportArraysMutex", 1, false];
	//Get the arrays
	private _reportObjects = +(_scriptObject getVariable ["AI_reportObjects", []]);
	private _reportPos= +(_scriptObject getVariable ["AI_reportPos", []]);
	private _reportAge = +(_scriptObject getVariable ["AI_reportAge", []]);
	//Unlock the mutex
	_scriptObject setVariable ["AI_reportArraysMutex", 0, false];
	
	//Return value
	[_reportObjects, _reportPos, _reportAge]
};

AI_fnc_getRequestedAlertState =
{
	params ["_so"]; //script object
	_so getVariable ["AI_requestedAS", 0]
};
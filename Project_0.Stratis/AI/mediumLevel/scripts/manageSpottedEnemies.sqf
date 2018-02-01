/*
Functions to get data from a medium level script object AI_fnc_manageSpottedEnemies.
*/

AI_fnc_getReportedEnemies =
{
	params ["_so"]; //script object
	//Wait until the arrays have been released (see manageSpottedEnemies.sqf)
	waitUntil {(_so getVariable ["AI_reportArraysMutex", 0]) == 0};
	//Lock the mutex
	_so setVariable ["AI_reportArraysMutex", 1, false];
	//Get the arrays
	private _reportObjects = +(_so getVariable ["AI_reportObjects", []]);
	private _reportPos= +(_so getVariable ["AI_reportPos", []]);
	private _reportAge = +(_so getVariable ["AI_reportAge", []]);
	//Unlock the mutex
	_so setVariable ["AI_reportArraysMutex", 0, false];
	
	//Return value
	[_reportObjects, _reportPos, _reportAge]
};

AI_fnc_getRequestedAlertState =
{
	params ["_so"]; //script object
	_so getVariable ["AI_requestedAS", 0]
};

AI_fnc_mediumLevel_getSide =
{
	params ["_so"];
	_so getVariable "AI_side";
};
/*
Event handler for killed units
It seems to be working even if unit's simulation is disabled
*/

//Remove the unit from garrison

private _unitHandle = _this select 0;

diag_log format ["fn_EH_killed.sqf: unit was killed: %1", _unitHandle];

//Get unit's garrison object
private _garrison = _unitHandle getVariable ["g_garrison", objNull];

[_garrison, _unitHandle] call gar_fnc_removeUnit;

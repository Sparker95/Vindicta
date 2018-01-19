#include "..\..\..\Garrison\garrison.hpp"

#define DEBUG

params ["_to"];

//Initialize variables
private _taskParams = _to getVariable "AI_taskParams";
private _garTransport = _to getVariable "AI_garrison";
private _garsCargo = _garTransport call gar_fnc_getCargoGarrisons;
private _garCargo = objNull;
if (count _garsCargo == 0) exitWith
{
	_to setVariable ["AI_taskState", "FAILURE"];
	_to setVariable ["AI_failReason", "NO_CARGO"];
};
_garCargo = _garsCargo select 0;

//Now wait until the infantry dismounts the vehicles
private _run = true;
while {_run} do
{
	sleep 2;
	//Check if all the cargo units have dissappeared?
	private _allCargoUnitHandles = _garCargo call gar_fnc_getAllUnitHandles;
	if(count _allCargoUnitHandles == 0) exitWith
	{
		_to setVariable ["AI_taskState", "FAILURE"];
		_to setVariable ["AI_failReason", "NO_CARGO"];
	};
	
	//Have you all dismounted??
	if(count _allCargoUnitHandles == count (_allCargoUnitHandles select {(vehicle _x isEqualTo _x)})) then
	{
		_to setVariable ["AI_taskState", "SUCCESS"];
		[_garTransport, _garCargo] call gar_fnc_removeCargoGarrison;
		_run = false;
	}
	else
	{
		//If not, then get out of your vehicles!
		//Assign cargo infantry to their vehicles
		_allCargoUnitHandles orderGetIn false;
		{
			unassignVehicle _x;
			//If debug, move them out of their vehicle fast
			#ifdef DEBUG
			moveOut _x;
			#endif
		} forEach _allCargoUnitHandles;
	};
};

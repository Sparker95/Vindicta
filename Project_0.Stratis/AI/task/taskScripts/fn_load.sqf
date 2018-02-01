/*
Ideas:
Check cargo that is already loaded
Check how much space is available
Check all loading methods

Possible cargo loading methods:
assignAsCargo, orderGetIn			- infantry + any kind of transport
Our own logistics script			- cargo boxes + land vehicles
Sling loading						- vehicles + helicopters
Vehicle in vehicle					- vehicles + a few specific vehicles like VTOL cargo planes
Disassemble & put into inventory	- static weapons + any vehicles. Or just disassemble and put them into a box?
*/

#include "..\..\..\Garrison\garrison.hpp"

#define SLEEP_TIME 2
#define SLEEP_RESOLUTION 0.01
#define DEBUG

params ["_to"];

private _hScript = _to spawn
{
	params ["_to"];
	//Initialize variables
	private _taskParams = _to getVariable "AI_taskParams";
	_taskParams params ["_garCargo"];
	private _garTransport = _to getVariable "AI_garrison";
	
	if(!([_garTransport, [_garCargo]] call gar_fnc_canLoadCargo)) exitWith
	{
		_to setVariable ["AI_taskState", "FAILURE"];
		_to setVariable ["AI_failReason", "CANT_LOAD"];
	};
	
	//Form a single group for vehicles
	[_garTransport, _garCargo] call AI_fnc_formVehicleGroup;
	
	//Now wait until the infantry boards the vehicles
	private _run = true;
	private _t = time;
	while {_run && (_to getVariable "so_run")} do
	{	
		//Check if all the cargo units have dissappeared?
		private _allCargoUnitHandles = _garCargo call gar_fnc_getAllUnitHandles;
		if(count _allCargoUnitHandles == 0) exitWith
		{
			_to setVariable ["AI_taskState", "FAILURE"];
			_to setVariable ["AI_failReason", "NO_CARGO"];
		};
		
		//Check if our cargo loading capabilities are gone
		if(!([_garTransport, [_garCargo]] call gar_fnc_canLoadCargo)) exitWith
		{
			_to setVariable ["AI_taskState", "FAILURE"];
			_to setVariable ["AI_failReason", "NO_TRANSPORT"];
		};
		
		//Check if all the cargo units have been loaded
		private _allInfantryHandles = [];
		{
			_allInfantryHandles pushBack _x;
		} forEach _allCargoUnitHandles;
		
		private _allTransportInfantry = [_garTransport, T_INF, -1] call gar_fnc_findUnits;
		{
			_allInfantryHandles pushBack ([_garTransport, _x] call gar_fnc_getUnitHandle);
		} forEach _allTransportInfantry;
		
		//Have you all mounted??
		if(count _allCargoUnitHandles == count (_allCargoUnitHandles select {!(vehicle _x isEqualTo _x)})) then
		{
			_to setVariable ["AI_taskState", "SUCCESS"];
			[_garTransport, _garCargo] call gar_fnc_addCargoGarrison;
			_run = false;
		}
		else
		{
			//If not, then get in your vehicles!
			//Assign cargo infantry to their vehicles
			[_garTransport, _garCargo] call AI_fnc_assignInfantryCargo;
			_allInfantryHandles orderGetIn true;
			#ifdef DEBUG
			{ //If debug, move them in their vehicle fast
				private _vr = assignedVehicleRole _x;
				private _v = assignedVehicle _x;
				[_v, _x, _vr] call BIS_fnc_moveIn;
			} forEach _allInfantryHandles;
			#endif
		};
		
		if(_run) then
		{
			//Update time variable
			_t = time + SLEEP_TIME;
			//SLeep and check if it's ordered to stop the thread
			waitUntil
			{
				sleep SLEEP_RESOLUTION;
				(time > _t) || (!(_to getVariable "so_run"))
			};
		};
	};
};

//Return script handle to the scriptObject_start
_hScript
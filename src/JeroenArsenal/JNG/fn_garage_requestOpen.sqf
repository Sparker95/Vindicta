#include "defineCommon.inc"
/*
	Author: Jeroen Notenbomer

	Description:
	Sends a command to the client to open the garage. It also adds the client to the serverlist so the server knows which players
	need to be updated when vehicles get removed/added/changed. This command needs to be excuted on the server!

	Parameter(s):
	ID clientOwner

	Returns:
	NOTHING, well it sends a command which contains the jng_vehicleList and jng_ammoList
*/

if(!isServer)exitWith{};
params ["_clientOwner","_object"];

 pr _temp = _object getVariable ["jng_inUseBy",[]];
_temp pushBackUnique _clientOwner;
_object setVariable ["jng_playersInGarage",_temp,true];

diag_log ["open Garage for: clientOwner ",_clientOwner];

//CALL_COMPILE_COMMON("JeroenArsenal\JNG\recompile.sqf");
["Open",[_object]] remoteExecCall ["jn_fnc_garage", _clientOwner];
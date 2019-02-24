#include "defineCommon.inc"
/*
	Author: Jeroen Notenbomer

	Description:
	Removes the client from the servers list so it doesnt get called when the garage gets updated. This command needs to be excuted on the server!

	Parameter(s):
	ID clientOwner

	Returns:
	NOTHING
*/

if(!isServer)exitWith{};
params ["_clientOwner","_object"];

_temp = _object getVariable ["jng_inUseBy",[]];
_temp= _temp - [_clientOwner];
_object setVariable ["jng_inUseBy",_temp];

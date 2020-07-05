#include "defineCommon.inc"


/*
	Author: Jeroen Notenbomer

	Description:
	Removes the client from the servers list so it doesnt get called when the arsenal gets updated. This command needs to be excuted on the server!

	Parameter(s):
	ID clientOwner

	Returns:
	NOTHING, well it sends a command which contains the JNA_datalist
*/

if(!isServer)exitWith{};
params ["_clientOwner","_object"];

_temp = _object getVariable ["jna_inUseBy",[]];
_temp = _temp - [_clientOwner];
_object setVariable ["jna_inUseBy",_temp,true];
diag_log format["JNC request closed: %1, new jna_inUseBy: %2", _this, _temp];
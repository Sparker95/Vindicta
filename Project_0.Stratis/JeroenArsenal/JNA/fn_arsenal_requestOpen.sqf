#include "defineCommon.inc"

/*
	Author: Jeroen Notenbomer

	Description:
	Sends a command to the client to open the arsenal. It also adds the client to the serverlist so it knows which players need to be updated if a item gets removed/added. This command needs to be excuted on the server!

	Parameter(s):
	ID clientOwner

	Returns:
	NOTHING, well it sends a command which contains the JNA_datalist
*/

if(!isServer)exitWith{};
params ["_clientOwner","_object"];

pr _temp = _object getVariable ["jna_inUseBy",[]];
_temp pushBackUnique _clientOwner;
_object setVariable ["jna_inUseBy",_temp,true];


pr _jna_dataList = _object getVariable "jna_dataList";

diag_log ["open arsenal for: clientOwner ",_clientOwner,_object];
["Open",[_jna_dataList]] remoteExecCall ["jn_fnc_arsenal", _clientOwner];


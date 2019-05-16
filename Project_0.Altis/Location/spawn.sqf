#include "..\OOP_Light\OOP_Light.h"
#include "..\MessageReceiver\MessageReceiver.hpp"
// Class: Location
/*
Method: spawn
Spawns Location.

Threading: should be called through postMethod (see <MessageReceiverEx>)

Returns: nil
*/

params [P_THISOBJECT];


OOP_INFO_0("SPAWN");

ASSERT_THREAD(_thisObject);


private _spawned = GET_VAR(_thisObject, "spawned");

if (_spawned) exitWith {
	OOP_ERROR_0("Already spawned");
	DUMP_CALLSTACK;
};

// Set spawned flag
SET_VAR(_thisObject, "spawned", true);


//spawn civilians
private _cpModule = GET_VAR(_thisObject, "cpModule");
[_cpModule] call CivPresence_fnc_spawn; 

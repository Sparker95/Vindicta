#include "..\common.h"
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


private _spawned = T_GETV("spawned");

if (_spawned) exitWith {
	OOP_ERROR_0("Already spawned");
	DUMP_CALLSTACK;
};

// Set spawned flag
T_SETV("spawned", true);

//force immediate spawn update of the garrison
{
	CALLM2(_x, "postMethodAsync", "updateSpawnState", []);
} forEach T_GETV("garrisons");

CALLM2(gGameMode, "postMethodAsync", "locationSpawned", [_thisObject]);
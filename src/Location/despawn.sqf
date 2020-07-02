#include "..\common.h"
#include "..\MessageReceiver\MessageReceiver.hpp"
#include "Location.hpp"

// Class: Location
/*
Method: spawn
Despawns location

Threading: should be called through postMethod (see <MessageReceiverEx>)

Returns: nil
*/

params [P_THISOBJECT];

OOP_INFO_0("DESPAWN");

ASSERT_THREAD(_thisObject);

private _spawned = T_GETV("spawned");
if (!_spawned) exitWith {
	OOP_ERROR_0("Already despawned");
	DUMP_CALLSTACK;
};

// Reset spawned flag
T_SETV("spawned", false);

// Reset counters
private _stAll = T_GETV("spawnPosTypes");
{
	_x set [LOCATION_SPT_ID_COUNTER, 0];
} forEach _stAll;

CALLM2(gGameMode, "postMethodAsync", "locationDespawned", [_thisObject]);

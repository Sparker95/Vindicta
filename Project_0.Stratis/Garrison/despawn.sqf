#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"

// Class: Garrison
/*
Method: spawn
Despawns all groups and units in this garrison.

Threading: should be called through postMethod (see <MessageReceiverEx>)

Returns: nil
*/

#define pr private

params [["_thisObject", "", [""]]];

private _spawned = GET_VAR(_thisObject, "spawned");

if (!_spawned) exitWith { diag_log format ["[Garrison::despawn] Error: Can't despawn a garrison which is not spawned: %1",
	GET_VAR(_thisObject, "debugName")]; };

// Reset spawned flag
SET_VAR(_thisObject, "spawned", false);

// Delete the AI object
// We delete it instantly because Garrison AI is in the same thread
pr _AI = GETV(_thisObject, "AI");
DELETE(_AI);
SETV(_thisObject, "AI", "");

private _units = GET_VAR(_thisObject, "units");
private _groups = GET_VAR(_thisObject, "groups");

// Despawn groups
{
	private _group = _x;
	CALLM(_group, "despawn", []);
} forEach _groups;

// Despawn single units
{
	private _unit = _x;
	if (CALL_METHOD(_x, "getGroup", []) == "") then {
		CALL_METHOD(_unit, "despawn", []);
	};
} forEach _units;
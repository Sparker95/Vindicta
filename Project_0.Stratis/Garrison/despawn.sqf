#include "common.hpp"
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

OOP_INFO_0("DESPAWN");

if (!_spawned) exitWith {
	OOP_ERROR_0("Already despawned");
};

// Reset spawned flag
SET_VAR(_thisObject, "spawned", false);

// Delete the AI object
// We delete it instantly because Garrison AI is in the same thread
pr _AI = GETV(_thisObject, "AI");
DELETE(_AI);
SETV(_thisObject, "AI", "");

private _units = GET_VAR(_thisObject, "units");
private _groups = (GET_VAR(_thisObject, "groups"));
private _groupsCopy = +_groups;

// Despawn groups, delete empty groups
{
	private _group = _x;
	CALLM(_group, "despawn", []);
	
	pr _units = CALLM0(_x, "getUnits");
	if (count _units == 0) then {
		_groups deleteAt (_groups find _x);
		DELETE(_group);
	};
} forEach _groups;


// Despawn single units
{
	private _unit = _x;
	if (CALL_METHOD(_x, "getGroup", []) == "") then {
		CALL_METHOD(_unit, "despawn", []);
	};
} forEach _units;
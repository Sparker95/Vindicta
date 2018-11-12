/*
Despawns the whole garrison
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"

#define pr private

params [["_thisObject", "", [""]]];

private _spawned = GET_VAR(_thisObject, "spawned");

if (!_spawned) exitWith { diag_log format ["[Garrison::despawn] Error: Can't despawn a garrison which is not spawned: %1",
	GET_VAR(_thisObject, "debugName")]; };

// Reset spawned flag
SET_VAR(_thisObject, "spawned", false);

// Delete the AI object
pr _AI = GETV(_thisObject, "AI");
DELETE(_AI);

private _units = GET_VAR(_thisObject, "units");
private _groups = GET_VAR(_thisObject, "groups");

// Despawn groups
{
	private _group = _x;
	CALLM(_group, "despawn");
} forEach _groups;

// Despawn single units
{
	private _unit = _x;
	if (CALL_METHOD(_x, "getGroup", []) == "") then {
		CALL_METHOD(_unit, "despawn", []);
	};
} forEach _units;
/*
Despawns the whole garrison
*/

#include "..\OOP_Light\OOP_Light.h"

params [["_thisObject", "", [""]]];

private _spawned = GET_VAR(_thisObject, "spawned");

if (!_spawned) exitWith { diag_log format ["[Garrison::despawn] Error: Can't despawn a garrison which is not spawned: %1",
	GET_VAR(_thisObject, "debugName")]; };

// Reset spawned flag
SET_VAR(_thisObject, "spawned", false);

private _units = GET_VAR(_thisObject, "units");
private _groups = GET_VAR(_thisObject, "groups");

// Despawn groups
{
	private _group = _x;
	private _groupUnits = CALL_METHOD(_group, "getUnits", []);
	{
		private _unit = _x;
		CALL_METHOD(_unit, "despawn", []);
	} forEach _groupUnits;
} forEach _groups;

// Despawn single units
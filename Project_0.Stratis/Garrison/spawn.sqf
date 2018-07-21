/*
Spawns the whole garrison
*/

#include "..\OOP_Light\OOP_Light.h"

params [["_thisObject", "", [""]]];

private _spawned = GET_VAR(_thisObject, "spawned");

if (_spawned) exitWith { diag_log "[Garrison::spawn] Error: Can't spawn a garrison which is already spawned"; };

// Set spawned flag
SET_VAR(_thisObject, "spawned", true);

private _units = GET_VAR(_thisObject, "units");
private _groups = GET_VAR(_thisObject, "groups");

// Spawn groups
{
	private _group = _x;
	private _groupUnits = CALL_METHOD(_group, "getUnits", []);
	{
		private _unit = _x;
		private _pos = getPos player;
		_pos = _pos vectorAdd [random 10, random 10, 0];
		private _posAndDir = [_pos, 0];
		CALL_METHOD(_unit, "spawn", _posAndDir);
	} forEach _groupUnits;
} forEach _groups;

// Spawn single units
#include "common.hpp"
#include "..\OOP_Light\OOP_Light.h"

// Class: Garrison
/*
Method: spawn
Spawns all groups and units in this garrison, if it's not currently spawned.

Threading: should be called through postMethod (see <MessageReceiverEx>)

Returns: nil
*/


#define pr private

params [["_thisObject", "", [""]]];

OOP_INFO_0("SPAWN");

private _spawned = GET_VAR(_thisObject, "spawned");

if (_spawned) exitWith {
	OOP_ERROR_0("Can't spawn a garrison which is already spawned");
};

// Set spawned flag
SET_VAR(_thisObject, "spawned", true);

private _units = GET_VAR(_thisObject, "units");
private _groups = GET_VAR(_thisObject, "groups");
private _loc = GET_VAR(_thisObject, "location");

// Spawn groups
{
	private _group = _x;
	CALLM(_group, "spawn", [_loc]);
} forEach _groups;

// Spawn single units
{
	private _unit = _x;
	if (CALL_METHOD(_x, "getGroup", []) == "") then {
		private _unitData = CALL_METHOD(_unit, "getMainData", []);
		private _args = _unitData + [0]; // ["_catID", 0, [0]], ["_subcatID", 0, [0]], ["_className", "", [""]], ["_groupType", "", [""]]
		private _posAndDir = CALL_METHOD(_loc, "getSpawnPos", _args);
		CALL_METHOD(_unit, "spawn", _posAndDir);
	};
} forEach _units;

// Create an AI brain of this garrison and start it
pr _AI = NEW("AIGarrison", [_thisObject]);
SETV(_thisObject, "AI", _AI);
CALLM(_AI, "start", []); // Let's start the party! \o/
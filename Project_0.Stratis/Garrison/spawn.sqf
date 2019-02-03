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

private _spawned = GET_VAR(_thisObject, "spawned");

if (_spawned) exitWith {
	diag_log format ["[Garrison::spawn] Error: Can't spawn a garrison which is already spawned: %1", GET_VAR(_thisObject, "debugName")];
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

// Create a goal object for this garrison
/*
private _args = [_thisObject]; // entity
private _newGoal = NEW("GoalComposite", _args);
CALLM(_newGoal, "setAutonomous", [3]); // timer interval
SETV(_thisObject, "goal", _newGoal);
*/
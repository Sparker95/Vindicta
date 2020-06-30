#include "common.hpp"
FIX_LINE_NUMBERS()
// Class: Garrison
/*
Method: spawn
Spawns all groups and units in this garrison, if it's not currently spawned.

Threading: should be called through postMethod (see <MessageReceiverEx>)

Returns: nil
*/


#define pr private

params [P_THISOBJECT, P_BOOL("_instantAction")];

OOP_INFO_0("SPAWN");

ASSERT_THREAD(_thisObject);

if(T_CALLM0("isDestroyed")) exitWith {
	OOP_WARNING_MSG("Attempted to call function on destroyed garrison %1", [_thisObject]);
	DUMP_CALLSTACK;
};

private _spawned = T_GETV("spawned");

if (_spawned) exitWith {
	OOP_WARNING_0("Already spawned");
	//DUMP_CALLSTACK;
};

// Set spawned flag
T_SETV("spawned", true);

private _units = T_GETV("units");
private _groups = T_GETV("groups");

// Let the action handle spawning
pr _AI = T_GETV("AI");
pr _action = CALLM0(_AI, "getCurrentAction");

if(_action != NULL_OBJECT) then { _action = CALLM0(_action, "getFrontSubaction"); };

pr _spawningHandled = if (_action != NULL_OBJECT) then {
	CALLM0(_action, "spawn");
} else {
	false
};

// Current action doesn't handle spawning
if (!_spawningHandled) then {
	private _loc = T_GETV("location");

	if (_loc != NULL_OBJECT) then {
		// If there is a location, spawn at it
		// Spawn groups
		OOP_INFO_1("Spawning groups: %1", _groups);
		{
			private _group = _x;
			CALLM1(_group, "spawnAtLocation", _loc);
		} forEach _groups;

		// Spawn single units
		{
			private _unit = _x;
			if (CALLM0(_x, "getGroup") == NULL_OBJECT) then {
				private _prevLoc = CALLM0(_x, "getDespawnLocation");
				if (_prevLoc == _loc && _prevLoc != NULL_OBJECT) then {
					// Spawn at the previous spawn position
					CALLM3(_unit, "spawn", [0 ARG 0 ARG 0], 0, true);
				} else {
					// Get new spawn position
					private _unitData = CALLM0(_unit, "getMainData");
					private _args = _unitData + [0]; // P_NUMBER("_catID"), P_NUMBER("_subcatID"), P_STRING("_className"), P_STRING("_groupType")
					private _posAndDir = CALLM(_loc, "getSpawnPos", _args);
					CALLM(_unit, "spawn", _posAndDir);
				};
			};
		} forEach _units;
	} else {
		// Otherwise spawn everything around some road
		private _garPos = T_CALLM0("getPos");
		// Otherwise spawn everything around garrison position
		private _global = T_GETV("type") == GARRISON_TYPE_AMBIENT;

		OOP_INFO_2("Spawning groups without location at pos %1: %2", _groups, _garPos);
		{
			CALLM2(_x, "spawnAtPos", _garPos, _global);
		} forEach _groups;

		// Spawn single units
		{
			CALLM3(_x, "spawn", _garPos, 0, _global);
		} forEach (_units select { CALLM0(_x, "getGroup") == NULL_OBJECT });
	};
};

// Call onGarrisonSpawned
if (_action != NULL_OBJECT) then {
	OOP_INFO_1("Calling %1.onGarrisonSpawned", _action);
	CALLM0(_action, "onGarrisonSpawned");
} else {
	OOP_INFO_0("SPAWN: no current action");
};

// Update process interval of AI
//CALLM1(_AI, "setProcessInterval", AI_GARRISON_PROCESS_INTERVAL_SPAWNED);

// Change process category if it's active
if (T_CALLM0("hasAI")) then {
	CALLM1(_AI, "addToProcessCategory", "AIGarrisonSpawned");
	// Call AI "process" method to accelerate decision taking
	// Pass the _accelerate flag to update sensors sooner, and allow instant completion of some actions
	CALLM1(_AI, "process", _instantAction);
};

0
#include "common.hpp"

// Class: Garrison
/*
Method: spawn
Spawns all groups and units in this garrison, if it's not currently spawned.

Threading: should be called through postMethod (see <MessageReceiverEx>)

Returns: nil
*/


#define pr private

params [P_THISOBJECT, P_BOOL("_global")];

OOP_INFO_0("SPAWN");

ASSERT_THREAD(_thisObject);

if(T_CALLM("isDestroyed", [])) exitWith {
	OOP_WARNING_MSG("Attempted to call function on destroyed garrison %1", [_thisObject]);
};

private _spawned = GET_VAR(_thisObject, "spawned");

if (_spawned) exitWith {
	OOP_ERROR_0("Already spawned");
	DUMP_CALLSTACK;
};

// Set spawned flag
SET_VAR(_thisObject, "spawned", true);

private _units = GET_VAR(_thisObject, "units");
private _groups = GET_VAR(_thisObject, "groups");

// Let the action handle spawning
pr _AI = T_GETV("AI");
pr _action = CALLM0(_AI, "getCurrentAction");

if(_action != NULL_OBJECT) then { _action = CALLM0(_action, "getFrontSubaction"); };

pr _spawningHandled = if (_action != NULL_OBJECT) then {
	ASSERT_MSG(!_global, "Global garrison should not have an active action");
	CALLM0(_action, "spawn");
} else {
	false
};

if (!_spawningHandled) then {
	// If there is no current action (how is that possible??) we perform spawning manually

	private _loc = GET_VAR(_thisObject, "location");

	if (_loc != NULL_OBJECT) then {
		// If there is a location, spawn at it
		// Spawn groups
		OOP_INFO_1("Spawning groups: %1", _groups);
		{
			private _group = _x;
			CALLM(_group, "spawnAtLocation", [_loc]);
		} forEach _groups;

		// Spawn single units
		{
			private _unit = _x;
			if (CALL_METHOD(_x, "getGroup", []) == NULL_OBJECT) then {
				private _prevLoc = CALLM0(_x, "getDespawnLocation");
				if (_prevLoc == _loc && _prevLoc != NULL_OBJECT) then {
					// Spawn at the previous spawn position
					CALLM3(_unit, "spawn", [0 ARG 0 ARG 0], 0, true);
				} else {
					// Get new spawn position
					private _unitData = CALL_METHOD(_unit, "getMainData", []);
					private _args = _unitData + [0]; // ["_catID", 0, [0]], ["_subcatID", 0, [0]], ["_className", "", [""]], ["_groupType", "", [""]]
					private _posAndDir = CALL_METHOD(_loc, "getSpawnPos", _args);
					CALL_METHOD(_unit, "spawn", _posAndDir);
				};
			};
		} forEach _units;
	} else {
		// Otherwise spawn everything around some road
		pr _garPos = CALLM0(_thisObject, "getPos");
		{
			CALLM2(_x, "spawnVehiclesOnRoad", [], _garPos);
		} forEach _groups;

		// Spawn single units
		{
			CALLM3(_x, "spawn", [0 ARG 0 ARG 0], 0, true);
		} forEach (_units select { CALL_METHOD(_x, "getGroup", []) == NULL_OBJECT });
	};
};

// Call onGarrisonSpawned
if (_action != "") then {
	OOP_INFO_1("Calling %1.onGarrisonSpawned", _action);
	CALLM0(_action, "onGarrisonSpawned");
} else {
	OOP_INFO_0("SPAWN: no current action");
};

// Update process interval of AI
//CALLM1(_AI, "setProcessInterval", AI_GARRISON_PROCESS_INTERVAL_SPAWNED);

// Change process category if it's active
if (T_GETV("active")) then {
	pr _msgLoop = CALLM0(_thisObject, "getMessageLoop");
	CALLM1(_msgLoop, "deleteProcessCategoryObject", _AI);
	CALLM2(_msgLoop, "addProcessCategoryObject", "AIGarrisonSpawned", _AI);
};

// Call AI "process" method to accelerate decision taking
CALLM1(_AI, "process", true); // Pass the _accelerate=true flag to update sensors sooner
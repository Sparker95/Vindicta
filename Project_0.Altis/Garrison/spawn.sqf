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

// Let the action handle spawning
pr _action = CALLM0(T_GETV("AI"), "getCurrentAction");
if(_action != "") then { _action = CALLM0(_action, "getFrontSubaction"); };
pr _spawningHandled = if (_action != "") then {
	CALLM0(_action, "spawn");
} else {
	false
};

if (!_spawningHandled) then {
	// If there is no current action (how is that possible??) we perform spawning manually
	// todo what happens if there is no location?

	private _loc = GET_VAR(_thisObject, "location");

	if (_loc != "") then {
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
			if (CALL_METHOD(_x, "getGroup", []) == "") then {
				private _unitData = CALL_METHOD(_unit, "getMainData", []);
				private _args = _unitData + [0]; // ["_catID", 0, [0]], ["_subcatID", 0, [0]], ["_className", "", [""]], ["_groupType", "", [""]]
				private _posAndDir = CALL_METHOD(_loc, "getSpawnPos", _args);
				CALL_METHOD(_unit, "spawn", _posAndDir);
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
			private _unit = _x;
			if (CALL_METHOD(_x, "getGroup", []) == "") then {
				pr _className = CALLM0(_unit, "getClassName");

				// Search for a free position in an area
				private _found = false;
				private _searchRadius = 50;
				pr _posAndDir = [];
				while {!_found} do {
					for "_i" from 0 to 8 do {
						pr _pos = _garPos vectorAdd [-_searchRadius + 2*_searchRadius, -_searchRadius + 2*_searchRadius, 0];
						if (CALLSM3("Location", "isPosSafe", _pos, 0, _className) && ! (surfaceIsWater _pos)) exitWith {
							_posAndDir = [_pos, 0];
							_found = true;
						};
					};
					
					if (!_found) then {
						// Search in a larger area at the next iteration
						_searchRadius = _searchRadius * 2;
					};			
				};

				// After a good place has been found, spawn it
				CALL_METHOD(_unit, "spawn", _posAndDir);
			};
		} forEach _units;
	};
};

// Call onGarrisonSpawned
if (_action != "") then {
	OOP_INFO_1("Calling %1.onGarrisonSpawned", _action);
	CALLM0(_action, "onGarrisonSpawned");
} else {
	OOP_INFO_0("SPAWN: no current action");
};
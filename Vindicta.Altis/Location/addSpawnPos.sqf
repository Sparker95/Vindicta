#include "Location.hpp"
#include "..\common.h"

// Class: Location
/*
Method: addSpawnPos
Adds a spawn position to to the spawn types array.

Parameters: _typesArray, _groupTypes, _pos, _dir, _building
_unitTypes - array with unit types
_groupTypes - array with group types
_pos - position
_dir - direction
_building - the building this pos. is attached to or objNull if it's not dependant on any building
*/

params [P_THISOBJECT, P_ARRAY("_unitTypes"), P_ARRAY("_groupTypes"), P_ARRAY("_pos"), P_NUMBER("_dir"), P_OBJECT("_building") ];

private _spawnPosTypes = T_GETV("spawnPosTypes"); //All spawn positions of this location

OOP_DEBUG_1("Adding spawn pos %1", _this);

// Check if a suitable array in spawn types already exists
// unit types and group types must match
private _stCurrent = if(count _spawnPosTypes > 0) then {
	_spawnPosTypes select { _x#LOCATION_SPT_ID_UNIT_TYPES isEqualTo _unitTypes && _x#LOCATION_SPT_ID_GROUP_TYPES isEqualTo _groupTypes };
} else {
	[]
};

// If a suitable array has not been found
private _spawnPos = [_pos, _dir, _building, 0];
if (count _stCurrent == 0) then {
	// Create a new array
	private _stNew = [_unitTypes, _groupTypes, [_spawnPos], 0];
	_spawnPosTypes pushBack _stNew;
} else {
	// Add this spawn position to the array
	private _posArray = _stCurrent#0#LOCATION_SPT_ID_SPAWN_POS;
	_posArray pushBack _spawnPos;
};

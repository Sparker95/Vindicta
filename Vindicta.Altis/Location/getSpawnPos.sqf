#include "..\common.h"
#include "..\Group\Group.hpp"
#include "..\Garrison\Garrison.hpp"
#include "Location.hpp"

// Class: Location
/*
Method: getSpawnPos
Gets a spawn position for a unit of specified category and subcategory.

Parameters: _catID, _subcatID, _className, _groupType
_catID - 
_subcatID - 
_className - 
_groupType - 

Return value: Array in format [[x, y, z], direction]

Author: Sparker 29.07.2018
*/

params [P_THISOBJECT, P_NUMBER("_catID"), P_NUMBER("_subcatID"), P_STRING("_className"), ["_groupType", GROUP_TYPE_INF, [GROUP_TYPE_INF]] ];

//First try to find it in building spawn positions
private _stAll = T_GETV("spawnPosTypes");

//Local variables
// private _stFound = []; //The return value

//Find spawn position which has specified unit type
private _found = false;
//private _ignoreGT = (_catID == T_VEH); //Ignore the group type check for this unit
private _posReturn = [];
private _dirReturn = 0;

if(_catID == T_INF) then { //For infantry we use the counter to check for free position, because inf can be spawned everywhere without blowing up
	private _i = 0;
	private _count = count _stAll;
	while { _i < _count && !_found } do {
		private _stCurrent = _stAll#_i;
		private _types = _stCurrent#LOCATION_SPT_ID_UNIT_TYPES;
		if([_catID, _subcatID] in _types &&
		  _groupType in _stCurrent#LOCATION_SPT_ID_GROUP_TYPES &&
		  count (_stCurrent#LOCATION_SPT_ID_SPAWN_POS) != _stCurrent#LOCATION_SPT_ID_COUNTER) then { //If maximum amount hasn't been reached
			private _positions = _stCurrent#LOCATION_SPT_ID_SPAWN_POS;
			private _nextFreePosID = _stCurrent#LOCATION_SPT_ID_COUNTER;
			private _posArray = _positions#_nextFreePosID;
			private _object = _posArray#LOCATION_SP_ID_BUILDING;
			if(isNil "_object" || {isNull _object} || {!isObjectHidden _object}) then {
				_posReturn = _posArray#LOCATION_SP_ID_POS;
				_dirReturn = _posArray#LOCATION_SP_ID_DIR;
				_stCurrent set [LOCATION_SPT_ID_COUNTER, _nextFreePosID + 1]; //Increment the counter
				_found = true;
			};
		};
		_i = _i + 1;
	};
} else { //For vehicles we use a special loc_fnc_isPosSafe function that checks if this place is occupied by something else
	private _i = 0;
	private _validSpots = _stAll select { [_catID, _subcatID] in _x#LOCATION_SPT_ID_UNIT_TYPES };
	private _count = count _validSpots;
	while { _i < _count && !_found } do {
		private _stCurrent = _validSpots#_i;
		// Find the first free spawn position
		private _positions = _stCurrent#LOCATION_SPT_ID_SPAWN_POS;
		private _foundIdx = _positions findIf {
			private _posArray = _x;
			private _cooldown = _posArray#LOCATION_SP_ID_COOLDOWN;
			private _object = _posArray#LOCATION_SP_ID_BUILDING;
			if(_cooldown < GAME_TIME && {isNil "_object" || {isNull _object} || {!isObjectHidden _object}}) then {
				// Check if given position is safe to spawn the unit here
				private _args = [_posArray#LOCATION_SP_ID_POS, _posArray#LOCATION_SP_ID_DIR, _className];
				CALL_STATIC_METHOD("Location", "isPosSafe", _args)
			} else {
				false
			}
		};
		if(_foundIdx != NOT_FOUND) then {
			private _posArray = _positions#_foundIdx;
			_posReturn = _posArray#LOCATION_SP_ID_POS;
			_dirReturn = _posArray#LOCATION_SP_ID_DIR;
			// 15 second cooldown for occuping spawn locations (this helps when allocating multiple spaces at the same time)
			_posArray set [LOCATION_SP_ID_COOLDOWN, GAME_TIME + 15];
			private _nextFreePosID = _stCurrent#LOCATION_SPT_ID_COUNTER;
			_stCurrent set [LOCATION_SPT_ID_COUNTER, _nextFreePosID + 1]; //Increment the counter, although it doesn't matter here
			_found = true;
		};
		_i = _i + 1;
	};
};

if(_found) then {
	OOP_DEBUG_MSG("Found premade spawn position for %1 at %2", [_className ARG _posReturn]);
} else {
	OOP_DEBUG_MSG("Failed to find premade spawn position for %1", [_className]);
};

//diag_log format ["123: %1", _stCurrent];
/*
Old code that finds spawn positions based on counter.
//todo delete it
if(_found) then //If the category has been found
{
	private _spawnPositions = _stCurrent select 1;
	private _nextFreePosID = _stCurrent select 2;
	_return = (_spawnPositions select _nextFreePosID) select [0, 4]; //Because the last element is _isInBuilding, which we don't need to return
	_stCurrent set [2, _nextFreePosID + 1]; //Increment the counter
}
else
{
	//Provide default spawn position
	private _r = 15; //0.5 * (_o getVariable ["l_radius", 0]);
	_return = ((getPos _o) vectorAdd [-_r + (random (2*_r)), -_r + (random (2*_r)), 0]) + [0];
	diag_log format ["fn_getSpawnPosition.sqf: warning: spawn position not defined for this type or maximum amount was reached: %1. Returning default position.", [_catID, _subcatID, _groupType]];
};

*/

private _return = if(_found) then {//If the spawn position has been found
	return [_posReturn, _dirReturn]
} else {
	//Provide default spawn position
	private _radius = (0.5 * (T_GETV("boundingRadius"))) min 60;
	private _locPos = T_GETV("pos");
	switch true do {
		case (_catID == T_INF): {
			return [_locPos getPos [random _radius, random 360], random 360];
		};
		case (_catID == T_VEH && _subcatID in T_VEH_heli): {
			return [_locPos, 250 max _radius, 15, 0.1] call misc_fnc_findSafeSpawnPos;
		};
		case (_catID == T_VEH && _subcatID in T_VEH_plane): {
			return [_locPos, 250 max _radius, 15, 0.01] call misc_fnc_findSafeSpawnPos;
		};
		case (_catID == T_VEH && _subcatID in T_VEH_ground): {
			// Try to find a random safe position on a road for this vehicle
			private _testPos = [_locPos, _radius min random [0, 0, _radius*5], random 360] call BIS_fnc_relPos;
			return CALLSM3("Location", "findSafePosOnRoad", _testPos, _className, 200 max (_radius * 2))
		};
		case (_catID == T_VEH && _subcatID in T_VEH_static): {
			// Try to find a random safe position on a road for this vehicle
			//private _testPos = [_locPos, _radius min random [0, 0, _radius*5], random 360] call BIS_fnc_relPos;
			return [_locPos, _radius, 3, 0.1] call misc_fnc_findSafeSpawnPos;
			// return CALLSM3("Location", "findSafePosOnRoad", _testPos, _className, 200 max (_radius * 2))
		};
		default {
			return [_locPos, _radius, 3, 0.3] call misc_fnc_findSafeSpawnPos;
		};
	};
};

return _return;

#include "..\OOP_Light\OOP_Light.h"
#include "..\Group\Group.hpp"
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

params [P_THISOBJECT, P_NUMBER("_catID"), P_NUMBER("_subcatID"), P_STRING("_className"), ["_groupType", GROUP_TYPE_IDLE, [GROUP_TYPE_IDLE]] ];

//First try to find it in building spawn positions
private _stAll = T_GETV("spawnPosTypes");

//Local variables
// private _stFound = []; //The return value

//Find spawn position which has specified unit type
private _found = false;
//private _ignoreGT = (_catID == T_VEH); //Ignore the group type check for this unit
private _posReturn = [];
private _dirReturn = 0;

if(_catID == T_INF) then //For infantry we use the counter to check for free position, because inf can be spawned everywhere without blowing up
{
	private _i = 0;
	private _count = count _stAll;
	while {_i < _count && !_found} do {
		private _stCurrent = _stAll select _i;
		private _types = _stCurrent select LOCATION_SPT_ID_UNIT_TYPES;
		if([_catID, _subcatID] in _types &&
		   ( _groupType in (_stCurrent select LOCATION_SPT_ID_GROUP_TYPES)) &&
		   ((count (_stCurrent select LOCATION_SPT_ID_SPAWN_POS)) != (_stCurrent select LOCATION_SPT_ID_COUNTER))) then { //If maximum amount hasn't been reached
			private _spawnPositions = _stCurrent select LOCATION_SPT_ID_SPAWN_POS;
			private _nextFreePosID = _stCurrent select LOCATION_SPT_ID_COUNTER;
			private _posArray = (_spawnPositions select _nextFreePosID);
			private _building = _posArray select LOCATION_SP_ID_BUILDING;
			if(isNil "_building" || {isNull _building} || {!isObjectHidden _building}) then {
				_posReturn = _posArray select LOCATION_SP_ID_POS;
				_dirReturn = _posArray select LOCATION_SP_ID_DIR;
				_stCurrent set [LOCATION_SPT_ID_COUNTER, _nextFreePosID + 1]; //Increment the counter
				_found = true;
			};
		};
		_i = _i + 1;
	};
} else { //For vehicles we use a special loc_fnc_isPosSafe function that checks if this place is occupied by something else
	private _i = 0;
	private _count = count _stAll;
	while {_i < _count && !_found} do {
		private _stCurrent = _stAll#_i;
		private _types = _stCurrent#LOCATION_SPT_ID_UNIT_TYPES;
		if([_catID, _subcatID] in _types) then {
			//Find the first free spawn position
			private _positions = _stCurrent#LOCATION_SPT_ID_SPAWN_POS;
			private _foundIdx = _positions findIf {
				private _posArray = _x;
				private _building = _posArray#LOCATION_SP_ID_BUILDING;
				if(isNil "_building" || {isNull _building} || {!isObjectHidden _building}) then {
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
				_found = true;
				private _nextFreePosID = _stCurrent#LOCATION_SPT_ID_COUNTER;
				_stCurrent set [LOCATION_SPT_ID_COUNTER, _nextFreePosID + 1]; //Increment the counter, although it doesn't matter here
			};
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

private _return = 0;
if(_found) then {//If the spawn position has been found
	OOP_INFO_3("[Location::getSpawnPos] Found spawn for %1 (%2): %3", [_catID ARG _subcatID ARG _groupType], _className, _return);
	_return = [_posReturn, _dirReturn];
} else {
	//Provide default spawn position
	if (_catID == T_INF) then {
		private _locToUse = _thisObject;
		// Walk up parents to the one we should use
		while {_groupType == GROUP_TYPE_PATROL && {GETV(_locToUse, "useParentPatrolWaypoints")}} do {
			_locToUse = GETV(_locToUse, "parent");
		};
		private _radius = (0.5 * (GETV(_locToUse, "boundingRadius"))) min 60;
		private _locPos = GETV(_locToUse, "pos");
		_return = [[_locPos#0 - _radius + random (2 * _radius), _locPos#1 - _radius + random (2 * _radius), 0], random 360];
		OOP_WARNING_3("[Location::getSpawnPos] Warning: spawn position not found for unit %1 (%2), returning random position %3", [_catID ARG _subcatID ARG _groupType], _className, _return);
	} else {
		// Try to find a random safe position on a road for this vehicle
		private _locPos = T_GETV("pos");
		private _locRadius = T_GETV("boundingRadius");
		private _testPos = [_locPos, _locRadius min random [0, 0, _locRadius*5], random 360] call BIS_fnc_relPos;
		// DUMP_CALLSTACK;
		// [[[_locPos, _locRadius]],[]] call BIS_fnc_randomPos;
		_return = CALLSM3("Location", "findSafePosOnRoad", _testPos, _className, 200 max (_locRadius * 2));
	};
};

_return
/*
Returns how many units of this type and group type the location can hold.

Parameters:
	_unitTypes - Number or Array
		- Number - catID
		- Array - array with [catID, subcatID] of the units
	_groupTypes - Array with group types

Author: Sparker 29.07.2018
*/

#include "Location.hpp"
#include "..\OOP_Light\OOP_Light.h"
#include "..\Group\Group.hpp"

params [ ["_thisObject", "", [""]], ["_unitTypes", 0, [[], 0]], ["_groupTypes", [], [[]]] ];

// Spawn Pos TypeS
private _spts = GET_VAR(_thisObject, "spawnPosTypes");

private _capacity = 0;

// Is _unitTypes a number or an array?
if (_unitTypes isEqualType 0) then {
	private _catID = _unitTypes;
	
	// Basic infantry capacity is not based on spawn positions but rather on buildings added to this location
	if (_catID == T_INF && (GROUP_TYPE_IDLE in _groupTypes) || (GROUP_TYPE_PATROL in _groupTypes)) then {
		_capacity = GET_VAR(_thisObject, "capacityInf");
	} else 	{
		{
			private _spt = _x;
			private _uts = _spt select LOCATION_SPT_ID_UNIT_TYPES;
			private _gts = _spt select LOCATION_SPT_ID_GROUP_TYPES;
			if ( count (_groupTypes arrayIntersect _gts) > 0) then { // Check if any of provided group types is supported
				private _allCats = []; // All categories
				_uts apply {_allCats pushBackUnique (_x select 0);};
				if (_catID in _allCats) then {
					_capacity = _capacity + count (_spt select LOCATION_SPT_ID_SPAWN_POS); // Increase the capacity by the amount of units for which the spawn position is defined
				};
			};
		} forEach _spts;
	};
} else {
	{
		private _spt = _x;
		private _uts = _spt select LOCATION_SPT_ID_UNIT_TYPES;
		private _gts = _spt select LOCATION_SPT_ID_GROUP_TYPES;
		if ( count (_groupTypes arrayIntersect _gts) > 0) then { // Check if any of provided group types is supported
			if (count (_unitTypes arrayIntersect _uts) > 0) then {
				_capacity = _capacity + count (_spt select LOCATION_SPT_ID_SPAWN_POS); // Increase the capacity by the amount of units for which the spawn position is defined
			};
		};
	} forEach _spts;
};

_capacity
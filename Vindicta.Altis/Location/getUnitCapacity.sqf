#include "Location.hpp"
#include "..\common.h"
#include "..\Group\Group.hpp"
#include "..\Garrison\Garrison.hpp"

// Class: Location
/*
Method: getUnitCapacity
Returns how many units of this type and group type the location can hold.

Parameters: _unitTypes, _groupTypes
_unitTypes - Number or Array
	- Number - catID
	- Array - array with [catID, subcatID] of the units
_groupTypes - Array with group types

Returns: Number

Author: Sparker 29.07.2018
*/

params [P_THISOBJECT, ["_unitTypes", 0, [[], 0]], P_ARRAY("_groupTypes") ];

// Spawn Pos TypeS
private _spawnPosTypes = T_GETV("spawnPosTypes");

private _capacity = 0;

// Is _unitTypes a number or an array?
if (_unitTypes isEqualType 0) then {
	private _catID = _unitTypes;

	// Basic infantry capacity is not based on spawn positions but rather on buildings added to this location
	if (_catID == T_INF && (GROUP_TYPE_INF in _groupTypes)) then {
		_capacity = T_GETV("capacityInf");
	} else 	{
		{
			private _spawnPosType = _x;
			private _unitTypes = _spawnPosType select LOCATION_SPT_ID_UNIT_TYPES;
			private _groupTypes = _spawnPosType select LOCATION_SPT_ID_GROUP_TYPES;
			if ( count (_groupTypes arrayIntersect _groupTypes) > 0) then { // Check if any of provided group types is supported
				private _allCats = []; // All categories
				_unitTypes apply {_allCats pushBackUnique (_x select 0);};
				if (_catID in _allCats) then {
					_capacity = _capacity + count (_spawnPosType select LOCATION_SPT_ID_SPAWN_POS); // Increase the capacity by the amount of units for which the spawn position is defined
				};
			};
		} forEach _spawnPosTypes;
	};
} else {
	{
		private _spawnPosType = _x;
		private _unitTypes = _spawnPosType select LOCATION_SPT_ID_UNIT_TYPES;
		private _groupTypes = _spawnPosType select LOCATION_SPT_ID_GROUP_TYPES;
		if ( count (_groupTypes arrayIntersect _groupTypes) > 0) then { // Check if any of provided group types is supported
			if (count (_unitTypes arrayIntersect _unitTypes) > 0) then {
				_capacity = _capacity + count (_spawnPosType select LOCATION_SPT_ID_SPAWN_POS); // Increase the capacity by the amount of units for which the spawn position is defined
			};
		};
	} forEach _spawnPosTypes;
};

_capacity
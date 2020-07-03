#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#include "..\common.h"
#include "Location.hpp"
#include "..\Group\Group.hpp"
#include "..\Garrison\Garrison.hpp"

// Class: Location
/*
Method: build
Builds this location depending on its type
*/

//The main road of Altis
#define ROAD_WIDTH_BIG		14.1
//Medium road used in cities and between them
#define ROAD_WIDTH_MEDIUM	10.1 
//Dirt road
#define ROAD_WIDTH_SMALL	7.2

#define pr private

params [P_THISOBJECT];

if (T_GETV("isBuilt")) exitWith {};

if (T_GETV("type") == LOCATION_TYPE_ROADBLOCK) exitWith {
	pr _pos = T_GETV("pos");

	// Find the nearest road
	pr _roads = (_pos nearRoads 300) apply {[_x distance2D _pos, _x]};
	if(count _roads == 0) exitWith {
		OOP_WARNING_1("No roads found within 300m of this roadblock at %1?!", _pos);
	};
	_roads sort ASCENDING; // Ascending
	pr _road = _roads#0#1;
	pr _roadPos = getPos _road;
	pr _roadWidth = [_road, 0.2, 20] call misc_fnc_getRoadWidth;

	// Estimate roadblock type
	pr _roadblockType = "";
	//Check how many houses the road has nearby
	_no = nearestTerrainObjects [_roadPos, ["BUILDING", "HOUSE"], _roadWidth + 50, false, true];
	//diag_log format ["Checking road: %1  objects count: %2", _roadIndex, _count];
	pr _index = _no findIf {
		_bb = boundingBoxReal _x;
		_size = 1.5*vectorMagnitude [_bb select 0 select 0, _bb select 0 select 1, 0];
		((_x distance _road) < (_size + _roadWidth)) // True if too close to road
	};
	if(_index == -1) then //No houses around, check for fences and walls
	{
		pr _no = nearestTerrainObjects [_roadPos, ["FENCE", "WALL", "ROCK", "ROCKS", "HIDE"], _roadWidth + 50, false, true];
		_no findIf {
			_bb = boundingBoxReal _x;
			_size = 1.5*vectorMagnitude [_bb select 0 select 0, _bb select 0 select 1, 0];
			((_x distance _road) < (_size + _roadWidth)) // True if too close to road
		};
		if(_index == -1) then //No objects around, its a good country roadblock
		{
			// No walls around, it's a country roadblock
			_roadblockType = "country";
		} else {
			// Some walls around, it's a city roadblock
			_roadblockType = LOCATION_TYPE_CITY;
		};
	} else {
		_roadblockType = LOCATION_TYPE_CITY;
	};

	// Estimate if it's highway or not
	pr _isHighway = (_roadWidth > 0.5*(ROAD_WIDTH_MEDIUM + ROAD_WIDTH_BIG));
	pr _isCity = _roadblockType == LOCATION_TYPE_CITY;

	// Select the right file with the composition
	pr _files = [
		[
			["cmp_roadblock_enemy_medium_country_0.sqf"],
			["cmp_roadblock_enemy_medium_city_0.sqf"]
		],
		[
			["cmp_roadblock_enemy_big_country_0.sqf", "cmp_roadblock_enemy_big_country_1.sqf"],
			["cmp_roadblock_enemy_big_city_0.sqf", "cmp_roadblock_enemy_big_city_0.sqf"]
		]
	];
	
	pr _file = selectRandom (_files select _isHighway select _isCity);
	pr _objects = CALL_COMPILE_COMMON(("Location\Compositions\" + _file));

	// Delete surrounding trees
	pr _no = nearestTerrainObjects [_roadPos, ["TREE", "SMALL TREE", "BUSH"], 30, false, true];
	{hideObjectGlobal _x;} forEach _no;

	// Build it!	
	pr _roadDir = [_road] call misc_fnc_getRoadDirection;
	pr _objects = [_roadPos, _roadDir, _objects] call BIS_fnc_ObjectsMapper;
	
	// Add all the objects to the location
	// Enable their dynamic simulation
	// Broadcast to all clients so that they rotate the objects
	{
		T_CALLM1("addObject", _x);
		_x enableDynamicSimulation true;
		private _posWorld = getPosWorld _x;
		private _vdir = vectorDir _x;
		private _vup = vectorUp _x;
		[_x, _posWorld] remoteExec ["setPosWorld"];
		[_x, [_vdir, _vup]] remoteExec ["setVectorDirAndUp"];
	} forEach _objects;

	// The End!
	T_SETV_PUBLIC("isBuilt", true);
};

// OOP_ERROR_1("Build method is not implemented for location type: %1", T_GETV("type"));
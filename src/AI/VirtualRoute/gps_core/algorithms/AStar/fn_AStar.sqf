#include "..\..\macros.h"
/**
	@Author : 
		[Utopia] Amaury
	@Contributors :
		Code34
	@Creation : --
	@Modified : --
	@Description : 
		AStar algorithm
		http://theory.stanford.edu/~amitp/GameProgramming/ImplementationNotes.html
		https://en.wikipedia.org/wiki/A*_search_algorithm
		http://theory.stanford.edu/~amitp/GameProgramming/AStarComparison.html
		https://www.redblobgames.com/pathfinding/a-star/introduction.html
	@Return : OBJECT - hashTable
**/

params [
	"_startRoute",
	"_goalRoute",
	"_namespace",
	"_costFunction",
	"_distanceFunction",
	"_callbackArgs",
	["_debugDraw", false]
];

private _frontier = [];
private _counter = 0;
private _current = [];

private _came_from = [] call misc_fnc_hashTable_create;
private _cost_so_far = [] call misc_fnc_hashTable_create;

[_came_from,RID(_startRoute),objNull] call misc_fnc_hashTable_set;
[_frontier,0,_counter,_startRoute] call misc_fnc_PQ_insert;
[_cost_so_far,RID(_startRoute),0] call misc_fnc_hashTable_set;

for "_i" from 0 to 1 step 0 do {
	// check if frontier is empty
	if (_frontier isEqualTo []) exitWith {};

	// get road with lowest value in queue
	_current = [_frontier] call misc_fnc_PQ_get;

	if (_current isEqualTo _goalRoute) exitWith {};

	{
		_x params ["_next","_cost"];
		
		_new_cost = ([_cost_so_far,RID(_current)] call misc_fnc_hashTable_find) + ([_cost, _current, _next, _startRoute, _goalRoute, _callbackArgs] call _costFunction);
		if (!([_cost_so_far,RID(_next)] call misc_fnc_hashTable_exists)) then {
			_counter = _counter + 1;
			[_cost_so_far,RID(_next),_new_cost] call misc_fnc_hashTable_set;
			_priority = _new_cost + ([_current, _next, _startRoute, _goalRoute, _callbackArgs] call _distanceFunction);
			[_frontier,_priority,_counter,_next] call misc_fnc_PQ_insert;
			
			if(_debugDraw and !(isNil "gps_test_fnc_mapDrawLine")) then {
				[
					["start", getPos _current],
					["end", getPos _next],
					["color", "ColorBlack"],
					["size", 5],
					["id", "astar_" + str _next]
				] call gps_test_fnc_mapDrawLine;
			};

			[_came_from,RID(_next),_current] call misc_fnc_hashTable_set;
		}else{
			if (_new_cost < ([_cost_so_far,RID(_next)] call misc_fnc_hashTable_find)) then {
				_counter = _counter + 1;
				[_cost_so_far,RID(_next),_new_cost] call misc_fnc_hashTable_set;
				_priority = _new_cost + ([_current, _next, _startRoute, _goalRoute, _callbackArgs] call _distanceFunction);
				[_frontier,_priority,_counter,_next] call misc_fnc_PQ_insert;

				if(_debugDraw and !(isNil "gps_test_fnc_mapDrawLine")) then {
					[
						["start", getPos _current],
						["end", getPos _next],
						["color", "ColorBlack"],
						["size", 5],
						["id", "astar_" + str _next]
					] call gps_test_fnc_mapDrawLine;
				};

				[_came_from,RID(_next),_current] call misc_fnc_hashTable_set;
			};
		};
	} foreach ([_namespace,RID(_current)] call misc_fnc_hashTable_find);
};

if(_debugDraw and !(isNil "gps_test_fnc_mapDrawLine")) then {
	_allMarkers = allMapMarkers;
	{
		if (toLower _x find "astar_" >= 0) then
		{
			deleteMarkerLocal _x;
		};
	} forEach _allMarkers;
};

_came_from
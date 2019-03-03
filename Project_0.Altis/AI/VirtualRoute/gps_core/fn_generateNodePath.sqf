#include "macros.h"
/**
  @Author : [Utopia] Amaury
  @Creation : 8/06/17
  @Modified : 25/12/17
  @Description : 
  @Return : ARRAY - Array of road nodes
**/

params [
	["_startRoute",objNull,[objNull]],
	["_goalRoute",objNull,[objNull]],
	["_costFunction", { 
		params ["_base_cost", "_current", "_next", "_startRoute", "_goalRoute"];
		_base_cost
	}],
	["_distanceFunction", { 
		params ["_current", "_next", "_startRoute", "_goalRoute"];
		_goalRoute distance _next
	}]
];

private _start_t = time;
diag_log format ["[generateNodePath] %1, %2", _startRoute, _goalRoute];
private _came_from = [_startRoute,_goalRoute,gps_allCrossRoadsWithWeight,_costFunction,_distanceFunction] call gps_core_fnc_aStar;

if(_came_from isEqualTo []) then { throw "PATH_NOT_FOUND_CAMEFROM" };
diag_log format ["[generateNodePath] came_from: %1", _came_from];

private _current = _goalRoute;
private _path = [];

while {_current != _startRoute} do {
  _path pushBack _current;
  _current = [_came_from,str _current] call misc_fnc_hashTable_find;

  // if something went wrong
  if (isNil "_current") then { 
    diag_log format ["Path not found, route so far %1", _path];
    throw "PATH_NOT_FOUND_TO";
  };
};

diag_log format ["[generateNodePath] %1 node route calculated in %2s", count _path, time - _start_t];
_path pushBack _startRoute;
reverse _path;

_path
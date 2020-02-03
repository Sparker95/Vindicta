#include "macros.h"
/**
  @Author : [Utopia] Amaury
  @Creation : 5/02/17
  @Modified : 27/12/17
  @Description : functions to generate the full path from AStar node path
  @Return : ARRAY - array of roads
**/

params [
	["_path",[],[[]]]
];

private	_fullPath = [];

{// forEach _path;
	scopeName "path";

	private _road = _x;
	private _next = _path select (_forEachIndex + 1);
	private _linked = [_road] call gps_core_fnc_roadsConnectedTo;

	if (isNil "_next") exitWith {
		_fullPath pushBack _road;
	};

	{// forEach _linked;
		private _passedBy = [_road];
		private _currRoad = _x;
		private _previous = _road;

		// faster than while {true}
		for "_i" from 0 to 1 step 0 do {
			_connected = [_currRoad] call gps_core_fnc_roadsConnectedTo;

			_passedBy pushBack _currRoad;

			if (_currRoad isEqualTo _next) then {
				_passedBy deleteAt (count _passedBy -1);
				_fullPath append _passedBy;
				breakTo "path";
			};

			if (count _connected > 2) exitWith {};

			_old = _currRoad;
			
			{// forEach _connected;
				if !(_x isEqualTo _previous) exitWith {
					_previous = _currRoad;
					_currRoad = _x;
				};
			} forEach _connected;

			if(_currRoad isEqualTo _old) exitWith {};
		};
	} forEach _linked;
} forEach _path;

_fullPath
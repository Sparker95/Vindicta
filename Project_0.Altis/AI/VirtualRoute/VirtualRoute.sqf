#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING

#include "..\..\OOP_Light\OOP_Light.h"

#include "VirtualRoute.hpp"

#define pr private

CLASS("VirtualRoute", "")

	VARIABLE("from");
	VARIABLE("destination");

	VARIABLE("recalculateInterval");

	VARIABLE("costFn");
	VARIABLE("speedFn");

	VARIABLE("calculated");
	VARIABLE("failed");

	VARIABLE("route");
	VARIABLE("waypoints");
	VARIABLE("pos");
	VARIABLE("nextIdx");
	VARIABLE("currSpeed_ms");

	VARIABLE("stopped");
	VARIABLE("last_t");

	VARIABLE("complete");
	
	/*
	Method: new
	Initialize the route, and start evaluating it.
	
	Parameters: _from, _destination, _costFn, _speedFn

	_from - Position to start from (nearest road to here will be the actual starting position).
	_destination - Position to go to (nearest road to here will be the actual starting position).
	_recalculateInterval - NOT IMPLEMENTED, Optional,.recalcuate the route at this interval when updating. Recommended > 60s.
	_costFn - Optional, function to override cost evaluation for route nodes.
	_speedFn - Optional, function to override convoy speed, called during update.
	*/
	METHOD("new") {
		params [
			"_thisObject",
			"_from",
			"_destination",
			["_recalculateInterval", -1],
			["_costFn", ""],
			["_speedFn", ""]
		];
		
		T_SETV("from", _from);
		T_SETV("destination", _destination);
		T_SETV("recalculateInterval", _recalculateInterval);

		if(_costFn isEqualType "") then {
			pr _default_costFn = {
				params ["_base_cost", "_current", "_next", "_startRoute", "_goalRoute"];
				_base_cost
			};
			T_SETV("costFn", _default_costFn);
		} else {
			T_SETV("costFn", _costFn);
		};

		if(_speedFn isEqualType "") then {
			pr _default_speedFn = {
				params ["_road", "_next_road"];
				if([_road] call misc_fnc_isHighWay) exitWith {
					60 * 0.277778
				};
				40 * 0.277778
			};
			T_SETV("speedFn", _default_speedFn);
		} else {
			T_SETV("speedFn", _speedFn);
		};

		T_SETV("calculated", false);
		T_SETV("failed", false);

		T_SETV("route", []);
		T_SETV("waypoints", []);
		T_SETV("pos", []);
		T_SETV("nextIdx", 0);

		T_SETV("stopped", true);
		T_SETV("last_t", time);

		T_SETV("complete", false);

		[_thisObject] spawn {
			params ["_thisObject"];

			T_PRVAR(from);
			T_PRVAR(destination);
			T_PRVAR(costFn);

			private _startRoute = [_from, 1000, gps_blacklistRoads] call bis_fnc_nearestRoad;
			private _endRoute = [_destination, 1000, gps_blacklistRoads] call bis_fnc_nearestRoad;

			if (isNull _endRoute or isNull _startRoute) exitWith {
				T_SETV("failed", false);
			};

			// TODO: either add a way to remove fake nodes again OR just use the nearest node instead of adding fake ones
			[_startRoute] call gps_core_fnc_insertFakeNode;
			[_endRoute] call gps_core_fnc_insertFakeNode;

			// This gets the node to node path.
			private _path = [_startRoute,_endRoute,_costFn] call gps_core_fnc_generateNodePath;
			// This fills in all the actual roads between the nodes.
			private _fullPath = [_path] call gps_core_fnc_generatePathHelpers;

			T_SETV("route", _fullPath);

			// Generating waypoints for AI navigation
			private _waypoints = [getPos (_fullPath select 0)];
			private _last_junction = 0;
			for "_i" from 0 to count _fullPath - 1 do {
				private _current = _fullPath select _i;
				if(count ([gps_allCrossRoadsWithWeight, str _current] call misc_fnc_hashTable_find) > 1) then
				{
					_waypoints pushBack (getPos (_fullPath select floor((_i + _last_junction)/2)));
					_last_junction = _i;
				};
			};
			_waypoints pushBack getPos (_fullPath select (count _fullPath - 1));
			
			T_SETV("waypoints", _waypoints);

			T_SETV("nextIdx", 1);
			T_SETV("pos", getPos (_fullPath select 0));

			T_PRVAR(speedFn);

			// Speed for first section
			pr _currSpeed_ms = [_fullPath select 0, _fullPath select 1] call _speedFn;
			T_SETV("currSpeed_ms", _currSpeed_ms);

			// Set it last
			T_SETV("calculated", true);
		};
	} ENDMETHOD;

	/*
	Method: start
	Start moving during process calls.
	*/
	METHOD("start") {
		params ["_thisObject"];

		T_SETV("stopped", false);
		T_SETV("last_t", time);
	} ENDMETHOD;

	/*
	Method: stop
	Stop moving during process calls.
	*/
	METHOD("stop") {
		params ["_thisObject"];

		T_SETV("stopped", true);
		T_SETV("last_t", time);
	} ENDMETHOD;

	/*
	Method: process
	Update position, moving along route. Only moves if started.
	*/
	METHOD("process") {
		params ["_thisObject"];
		
		T_PRVAR(stopped);
		if( _stopped ) exitWith {};

		T_PRVAR(last_t);
		// Time since last update
		pr _dt = time - _last_t;
		T_SETV("last_t", time);

		// TODO: 
		// To make this work for large dt (> a few seconds) we should make it a loop:
		// while speed*dt > next_dist {
		// 	dt_to_next = next_dist / speed (check this is the correct math)
		//	dt = dt - dt_to_next
		//  nextIdx = nextIdx + 1 etc. (same as below, just move to the next section)
		// }
		// pos = pos + dist blah bah.

		// How far will should we travel?
		T_PRVAR(currSpeed_ms);
		pr _dist = _currSpeed_ms * _dt;

		// How far to the next node?
		T_PRVAR(pos);
		T_PRVAR(nextIdx);
		T_PRVAR(route);
		pr _next_pos = getPos (_route select _nextIdx);
		pr _next_dist = _pos distance _next_pos;

		// If we will reach the next node then...
		if(_dist >= _next_dist) then {

			// Just set our position to the next node itself. We lose a bit of accuracy here but it 
			// should be trivial.
			T_SETV("pos", _next_pos);

			// _pos = _next_pos;
			//T_PRVAR(nextIdx);

			_nextIdx = _nextIdx + 1;

			// If we didn't reach the end yet
			if(_nextIdx < count _route) then {
				T_PRVAR(speedFn);

				// Update speed for the next section
				_currSpeed_ms = [_route select _nextIdx - 1, _route select _nextIdx] call _speedFn;
				T_SETV("currSpeed_ms", _currSpeed_ms);

				//_next_pos = getPos (_route select _nextIdx);
				//T_SETV("_nextIdx", _nextIdx);
			} else {

			};

			T_SETV("nextIdx", _nextIdx);
		} else {
			// Update position
			_pos = _pos vectorAdd (vectorNormalized (_next_pos vectorDiff _pos) vectorMultiply _dist);
			T_SETV("pos", _pos);
		};
	} ENDMETHOD;

	/*
	Method: debugDraw
	Draw route and waypoints on map.

	Parameters: _routeColor, _waypointColor

	_routeColor - color to use to draw the route path.
	_waypointColor - color to use to draw waypoints
	*/
	METHOD("debugDraw") {
		params [
			"_thisObject",
			["_routeColor", "ColorBlue"],
			["_waypointColor", "ColorWhite"]
		];
		
		CALLM0(_thisObject, "clearDebugDraw");

		T_PRVAR(route);

		pr _path_pos = _route apply { getPos _x };
		pr _seg_positions = [_path_pos, 20] call gps_core_fnc_RDP;

		for "_i" from 0 to (count _seg_positions - 2) do
		{
			private _start = _seg_positions select _i;
			private _end = _seg_positions select (_i + 1);
			[
				["start", _start],
				["end", _end],
				["color", _routeColor],
				["size", 10],
				["id", "gps_route" + _thisObject + str _start + str _end]
			] call gps_test_fnc_mapDrawLine; 
		};

		T_PRVAR(waypoints);
		{
			[_x, "gps_waypoint_" + _thisObject + str _x, _waypointColor, "mil_dot"] call gps_test_fn_mkr;
		} forEach _waypoints;
		// pr _waypoints = T_GETV("waypoints");
	} ENDMETHOD;

	/*
	Method: clearDebugDraw
	Clear debug markers for this route.
	*/
	METHOD("clearDebugDraw") {
		params ["_thisObject"];
		["gps_route" + _thisObject] call gps_test_fn_clear_markers;
		["gps_waypoint" + _thisObject] call gps_test_fn_clear_markers;
	} ENDMETHOD;

	/*
	Method: clearDebugDraw
	Clear debug markers for all routes.
	*/
	STATIC_METHOD("clearAllDebugDraw") {
		["gps_route"] call gps_test_fn_clear_markers;
		["gps_waypoint"] call gps_test_fn_clear_markers;
	} ENDMETHOD;

ENDCLASS;

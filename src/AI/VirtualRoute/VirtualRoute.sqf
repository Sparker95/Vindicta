#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING

#include "..\..\common.h"
#include "VirtualRoute.hpp"

#define pr private

#define __GET_POS(a) (if ((a) isEqualType objNull) then {getPos (a)} else {(a)})

#define OOP_CLASS_NAME VirtualRoute
CLASS("VirtualRoute", "")

	VARIABLE_ATTR("recalculateInterval", [ATTR_PRIVATE]);

	VARIABLE_ATTR("costFn", [ATTR_PRIVATE]);
	VARIABLE_ATTR("speedFn", [ATTR_PRIVATE]);
	VARIABLE_ATTR("callbackArgs", [ATTR_PRIVATE]);

	VARIABLE_ATTR("route", [ATTR_PRIVATE]);
	VARIABLE_ATTR("pos", [ATTR_PRIVATE]);
	VARIABLE_ATTR("nextIdx", [ATTR_PRIVATE]);
	VARIABLE_ATTR("currSpeed_ms", [ATTR_PRIVATE]);

	VARIABLE_ATTR("stopped", [ATTR_PRIVATE]);
	VARIABLE_ATTR("last_t", [ATTR_PRIVATE]);

	VARIABLE_ATTR("from", [ATTR_GET_ONLY]);
	VARIABLE_ATTR("destination", [ATTR_GET_ONLY]);
	VARIABLE_ATTR("calculated", [ATTR_GET_ONLY]);
	VARIABLE_ATTR("failed", [ATTR_GET_ONLY]);
	VARIABLE_ATTR("waypoints", [ATTR_GET_ONLY]);
	VARIABLE_ATTR("complete", [ATTR_GET_ONLY]);

	VARIABLE_ATTR("debugDraw", [ATTR_PRIVATE]);

	VARIABLE_ATTR("infantry", [ATTR_PRIVATE]); // True if infantry path is used

	
	/*
	Method: new
	Initialize the route, and start evaluating it.
	
	Parameters: _from, _destination, _costFn, _speedFn

	_from - Position to start from (nearest road to here will be the actual starting position).
	_destination - Position to go to (nearest road to here will be the actual destination position).
	_recalculateInterval - NOT IMPLEMENTED, Optional,.recalcuate the route at this interval when updating. Recommended > 60s.
	_costFn - Optional, function to override cost evaluation for route nodes.
	_speedFn - Optional, function to override convoy speed, called during update.
	_async - Optional, bool, default true. If true, calculates the route in another thread. If false, calculates the route right now.
	_debugDraw - optional
	_infantry - if true, it will use a path finding for infantry. Does not support cost function yet.
	*/
	METHOD(new)
		params [
			P_THISOBJECT,
			"_from",
			"_destination",
			["_recalculateInterval", -1],
			["_costFn", ""],
			["_speedFn", ""],
			["_callbackArgs", []],
			["_async", true],
			["_debugDraw", false],
			["_infantry", false]
		];
		private _fromATL = [_from#0, _from#1, 0];
		private _destinationATL = [_destination#0, _destination#1, 0];
		T_SETV("from", _fromATL);
		T_SETV("destination", _destinationATL);
		T_SETV("recalculateInterval", _recalculateInterval);
		T_SETV("infantry", _infantry);

		T_SETV("callbackArgs", _callbackArgs);

		T_SETV("debugDraw", _debugDraw);

		if(_costFn isEqualType "") then {
			pr _default_costFn = {
				params ["_base_cost", "_current", "_next", "_startRoute", "_goalRoute", "_callbackArgs"];
				_base_cost
			};
			T_SETV("costFn", _default_costFn);
		} else {
			T_SETV("costFn", _costFn);
		};

#ifdef DEBUG_FAST_VIRTUALROUTE
		pr _fast_speedFn = { 120 * 0.277778 };
		T_SETV("speedFn", _fast_speedFn);
#else
		if(_speedFn isEqualType "") then {
			pr _default_speedFn = if (!_infantry) then {
				// Default vehicle speed function
				{
					params ["_road", "_next_road", "_callbackArgs"];
					if([_road] call misc_fnc_isHighWay) exitWith {
						60 * 0.277778
					};
					40 * 0.277778
				};
			} else {
				// Default infantry speed function
				{
					14.0 * 0.277778;
				};
			};
			T_SETV("speedFn", _default_speedFn);
		} else {
			T_SETV("speedFn", _speedFn);
		};
#endif
		FIX_LINE_NUMBERS()

		T_SETV("calculated", false);
		T_SETV("failed", false);

		T_SETV("route", []);
		T_SETV("waypoints", []);
		T_SETV("pos", []);
		T_SETV("nextIdx", 0);

		T_SETV("stopped", true);
		T_SETV("last_t", GAME_TIME);

		T_SETV("complete", false);

		T_SETV("currSpeed_ms", 0);

		if (!_infantry) then {
			T_CALLM1("_calcRouteGroundVehicles", _async);
		} else {
			T_CALLM1("_calcRouteInfantry", _async);
		};

	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		T_CALLM("waitUntilCalculated", []);

		private _debugDraw = T_GETV("debugDraw");
		if(_debugDraw) then {
			T_CALLM("clearDebugDraw", []);
		};
	ENDMETHOD;

	public METHOD(waitUntilCalculated)
		params [P_THISOBJECT];
		// Make sure calculation is terminated. If it isn't then we must have run it async, so we should be 
		// able to wait for it I guess?
		// hack for infantry route calculation, ignore waiting. It won't crash main thread anyway.
		if(!T_GETV("calculated") and !T_GETV("failed") and !T_GETV("infantry")) then {
			waitUntil {
				T_GETV("calculated") or T_GETV("failed")
			};
		};
	ENDMETHOD;

	METHOD(_calcRouteInfantry)
		params [P_THISOBJECT, P_BOOL("_async")];

		private _from = T_GETV("from");
		private _destination = T_GETV("destination");
		
		#ifndef _SQF_VM
		private _agent = calculatePath ["man","AWARE", _from, _destination];
		#else
		private _agent = "sqfvm" createVehicle [0,0,0];
		#endif
		_agent setVariable ["_virtualRoute", _thisObject];
		_agent addEventHandler ["PathCalculated", {
			params ["_agent", "_path"];

			if (isNull _agent) exitWith {};

			private _thisObject = _agent getVariable "_virtualRoute";

			// Bail if VirtualRoute is deleted already
			if (!IS_OOP_OBJECT(_thisObject)) exitWith {};

			private _from = T_GETV("from");
			private _destination = T_GETV("destination");
			private _costFn = T_GETV("costFn");
			private _callbackArgs = T_GETV("callbackArgs");
			private _debugDraw = T_GETV("debugDraw");

			OOP_INFO_1("Path calculated, nodes: %1", count _path);

			if (count _path < 2) exitWith {
				OOP_WARNING_2("VirtualRoute infantry path calculation failed between %1 and %2 (route has below 2 nodes)", str _from, str _destination);
				T_SETV("failed", true);
			};
			
			pr _lastWaypoint = _path select ((count _path) - 1);
			if (_lastWaypoint distance2D _destination > 50) exitWith {
				OOP_WARNING_2("VirtualRoute infantry path calculation failed between %1 and %2 (route end point is too far from destination)", str _from, str _destination);
				T_SETV("failed", true);
			};

			{
				_x set [2, 0]; // Reset vertical component
			} forEach _path;
			T_SETV("route", +_path);
			T_SETV("waypoints", +_path);

			// Speed for first section
			pr _speedFn = T_GETV("speedFn");
			pr _currSpeed_ms = [_fullPath select 0, _fullPath select 1, _callbackArgs] call _speedFn;
			T_SETV("currSpeed_ms", _currSpeed_ms);

			#ifndef RELEASE_BUILD
			if(_debugDraw) then {
				T_CALLM0("debugDraw");
			};
			#endif
			FIX_LINE_NUMBERS()

			// Set it last
			T_SETV("calculated", true);
			deleteVehicle _agent;
		}];
	ENDMETHOD;

	METHOD(_calcRouteGroundVehicles)
		params [P_THISOBJECT, P_BOOL("_async")];
		// Function that calculates the route
		pr _calcRoute = {
			SCOPE_ACCESS_MIMIC("VirtualRoute");
			params [P_THISOBJECT];

			private _from = T_GETV("from");
			private _destination = T_GETV("destination");
			private _costFn = T_GETV("costFn");
			private _callbackArgs = T_GETV("callbackArgs");
			private _debugDraw = T_GETV("debugDraw");

			private _startRoute = [_from, 2000, gps_blacklistRoads] call bis_fnc_nearestRoad;
			private _endRoute = [_destination, 2000, gps_blacklistRoads] call bis_fnc_nearestRoad;

			if (isNull _endRoute or isNull _startRoute) exitWith {
				T_SETV("failed", true);
			};

			// TODO: either add a way to remove fake nodes again OR just use the nearest node instead of adding fake ones
			[_startRoute] call gps_core_fnc_insertFakeNode;
			[_endRoute] call gps_core_fnc_insertFakeNode;

			try {
				// This gets the node to node path.
				// TODO: add cancellation token so we can cancel route calulation on delete (token = array wrapping a bool)
				private _path = [_startRoute,_endRoute,_costFn,"",_callbackArgs] call gps_core_fnc_generateNodePath;
				if(count _path < 2) then { // Replaced <=1 with <1 because it might make one waypoint if it's not too far to traverl
					// TODO: this could do something more intelligent. Probably ties in with travel to and from actual roads.
					throw "failed";
				};
				// This fills in all the actual roads between the nodes.
				private _fullPath = [_path] call gps_core_fnc_generatePathHelpers;
				T_SETV("route", _fullPath);

				// Generating waypoints for AI navigation
				private __wp0 = __GET_POS(_fullPath select 0);
				private _waypoints = [__wp0];
				private _last_junction = 0;
				for "_i" from 0 to count _fullPath - 1 do {
					private _current = _fullPath select _i;
					if(count ([gps_allCrossRoadsWithWeight, str _current] call misc_fnc_hashTable_find) > 1) then
					{
						pr _road = _fullPath select floor((_i + _last_junction)/2);
						pr _roadPosATL = getPosATL _road;
						// Ignore positions above ground
						if (_roadPosATL#2 < 0.25) then {
							_waypoints pushBack _roadPosATL;
							_last_junction = _i;
						};
					};
				};
				_waypoints pushBack __GET_POS(_fullPath select (count _fullPath - 1));

				T_SETV("waypoints", _waypoints);

				T_SETV("nextIdx", 1);
				T_SETV("pos", __GET_POS(_fullPath select 0));

				private _speedFn = T_GETV("speedFn");

				// Speed for first section
				pr _currSpeed_ms = [_fullPath select 0, _fullPath select 1, _callbackArgs] call _speedFn;
				T_SETV("currSpeed_ms", _currSpeed_ms);
				
#ifndef RELEASE_BUILD
				if(_debugDraw) then {
					T_CALLM0("debugDraw");
				};
#endif
				FIX_LINE_NUMBERS()
				// Set it last
				T_SETV("calculated", true);
			} catch {
				OOP_WARNING_2("VirtualRoute calculation failed between %1 and %2", str _from, str _destination);
				T_SETV("failed", true);
			};
		};

		// Calculate the route right now or asynchronously?
		if (_async) then {
			[_thisObject] spawn _calcRoute;
		} else {
			[_thisObject] call _calcRoute;
		};
	ENDMETHOD;

	/*
	Method: start
	Start moving during process calls.
	*/
	public METHOD(start)
		params [P_THISOBJECT];

		T_SETV("stopped", false);
		T_SETV("last_t", GAME_TIME);
	ENDMETHOD;

	/*
	Method: stop
	Stop moving during process calls.
	*/
	public METHOD(stop)
		params [P_THISOBJECT];

		T_SETV("stopped", true);
		T_SETV("last_t", GAME_TIME);
	ENDMETHOD;

	/*
	Method: process
	Update position, moving along route. Only moves if started.
	*/
	public METHOD(process)
		params [P_THISOBJECT];
		
		private _failed = T_GETV("failed");
		private _stopped = T_GETV("stopped");
		private _complete = T_GETV("complete");
		private _calculated = T_GETV("calculated");
		if(_failed or _stopped or _complete or !_calculated) exitWith {};

		private _last_t = T_GETV("last_t");
		// Time since last update
		pr _dt = GAME_TIME - _last_t;
		_dt = _dt min 30; // We want to limit the max amount of distance we can travel, otherwise it will appear that AIs teleport
		T_SETV("last_t", GAME_TIME);

		// How far to the next node?
		private _pos = T_GETV("pos");
		private _nextIdx = T_GETV("nextIdx");
		private _route = T_GETV("route");
		pr _nextPos = __GET_POS(_route select _nextIdx);
		pr _nextDist = _pos distance _nextPos;

		// How far will should we travel?
		private _currSpeed_ms = T_GETV("currSpeed_ms");
		//pr _dist = _currSpeed_ms * _dt;

		// If we will reach the next node then...
		while { _currSpeed_ms * _dt >= _nextDist and _nextIdx < count _route } do {

			// Set our position to the next node.
			_pos = _nextPos;
			_nextIdx = _nextIdx + 1;
			T_SETV("nextIdx", _nextIdx);

			// If we didn't reach the end yet
			if(_nextIdx < count _route) then {
				// Reduce dt by the time it took to reach the next node
				_dt = _dt - _nextDist / _currSpeed_ms;

				// Update speed for the next section
				private _speedFn = T_GETV("speedFn");
				_currSpeed_ms = [_route select _nextIdx - 1, _route select _nextIdx] call _speedFn;
				T_SETV("currSpeed_ms", _currSpeed_ms);

				_nextPos = __GET_POS(_route select _nextIdx);
				_nextDist = _pos distance _nextPos;

				// Delete this position from the waypoint array (if it is in the waypoint array)
				pr _waypoints = T_GETV("waypoints");
				if ((_waypoints#0) isEqualTo _nextPos) then {_waypoints deleteAt 0;};
			} else {
				T_SETV("complete", true);
			};
		};

		pr _dist = _currSpeed_ms * _dt;

		// Update position
		_pos = _pos vectorAdd (vectorNormalized (_nextPos vectorDiff _pos) vectorMultiply _dist);
		T_SETV("pos", _pos);

	ENDMETHOD;


	/*
	Method: getConvoyPositions
	Return a set of positions and directions for convoy vehicles.

	Parameters: _number, _spacing

	_number - Number of positions to return.
	_spacing - Optional, default 20, Spacing between positions.

	Returns: Array of position, dir pairs [[pos, dir], [pos, dir], ...].
	First array element corresponds to the lead vehicle.
	*/
	public METHOD(getConvoyPositions)
		params [
			P_THISOBJECT,
			"_number",
			["_spacing", 20]
		];
		
		// How far to the next node?
		private _pos = T_GETV("pos");
		private _nextIdx = T_GETV("nextIdx");
		private _route = T_GETV("route");
		
		// TODO: we could return some useful defaults here instead?
		ASSERT_MSG(!T_GETV("failed"), "Route calculation failed, cannot get convoy positions");
		ASSERT_MSG(T_GETV("calculated"), "Can't call getConvoyPositions until route has finished calculating");
		
		pr _startPos = __GET_POS(_route select 0);

		private _convoyPositions = [];

		// If we didn't move enough for the convoy to fit going back from current position
		// we will go forward from start.
		if(_pos distance _startPos < _spacing * _number) then {
			pr _currPos = _startPos;
			pr _index = 0;
			pr _nextPos = __GET_POS(_route select (_index + 1));
			for "_i" from 0 to (_number-1) do {
				_convoyPositions pushBack [_currPos, _currPos getDir _nextPos];
				pr _distNext = _currPos distance _nextPos;
				pr _distRemaining = _spacing;
				while {_distRemaining >= _distNext} do {
					_distRemaining = _distRemaining - _distNext;
					_index = _index + 1;
					_currPos = _nextPos;
					_nextPos = __GET_POS(_route select (_index + 1));
					_distNext = _currPos distance _nextPos;
				};
				_currPos = _currPos vectorAdd (vectorNormalized (_nextPos vectorDiff _currPos) vectorMultiply _distRemaining);
			};
			reverse _convoyPositions;
		} else {
			pr _currPos = _pos;
			pr _index = _nextIdx - 1;
			pr _prevPos = __GET_POS(_route select _index);
			for "_i" from 0 to (_number-1) do {
				_convoyPositions pushBack [_currPos, _prevPos getDir _currPos];
				pr _distPrev = _currPos distance _prevPos;
				pr _distRemaining = _spacing;
				while {_distRemaining >= _distPrev} do {
					_distRemaining = _distRemaining - _distPrev;
					_index = _index - 1;
					_currPos = _prevPos;
					_prevPos = __GET_POS(_route select _index);
					_distPrev = _currPos distance _prevPos;
				};
				_currPos = _currPos vectorAdd (vectorNormalized (_prevPos vectorDiff _currPos) vectorMultiply _distRemaining);
			};
		};

		_convoyPositions
	ENDMETHOD;

	/*
	Method: debugDraw
	Draw route and waypoints on map.

	Parameters: _routeColor, _waypointColor

	_routeColor - color to use to draw the route path.
	_waypointColor - color to use to draw waypoints
	*/
	METHOD(debugDraw)
		params [
			P_THISOBJECT,
			["_routeColor", "ColorBlack"],
			["_waypointColor", "ColorBlack"]
		];
		
		T_CALLM0("clearDebugDraw");

		private _route = T_GETV("route");

		pr _path_pos = if (_route#0 isEqualType objNull) then {
			_route apply { getPos _x };
		} else {
			_route;
		};
		pr _seg_positions = [_path_pos, 20] call gps_core_fnc_RDP;

		for "_i" from 0 to (count _seg_positions - 2) do
		{
			private _start = _seg_positions select _i;
			private _end = _seg_positions select (_i + 1);
			[
				["start", _start],
				["end", _end],
				["color", _routeColor],
				["size", 8],
				["id", "gps_route_" + _thisObject + str _start + str _end]
			] call gps_test_fnc_mapDrawLine;
		};

		 private _waypoints = T_GETV("waypoints");
		 {
		 	[_x, "gps_waypoint_" + _thisObject + str _x, _waypointColor, "mil_dot"] call gps_test_fn_mkr;
		 } forEach _waypoints;
	ENDMETHOD;

	/*
	Method: clearDebugDraw
	Clear debug markers for this route.
	*/
	METHOD(clearDebugDraw)
		params [P_THISOBJECT];
		["gps_route_" + _thisObject] call gps_test_fn_clear_markers;
		["gps_waypoint_" + _thisObject] call gps_test_fn_clear_markers;
	ENDMETHOD;

	/*
	Method: clearAllDebugDraw
	Clear debug markers for all routes.
	*/
	public STATIC_METHOD(clearAllDebugDraw)
		["gps_route_"] call gps_test_fn_clear_markers;
		["gps_waypoint_"] call gps_test_fn_clear_markers;
	ENDMETHOD;

	/*
	Method: getPos
	Returns: current position
	*/
	public METHOD(getPos)
		params [P_THISOBJECT];
		T_GETV("pos")
	ENDMETHOD;

	/*
	Method: sets the current position to the nearest position along the route.
	Returns: nothing
	*/
	public METHOD(setPos)
		params [P_THISOBJECT, P_ARRAY("_pos") ];

		if (T_GETV("calculated")) then {
			// Find the nearest pos in the route and its index
			pr _route = T_GETV("route");
			pr _i = 0;
			pr _count = count _route;
			pr _index = 0;
			pr _dist = (__GET_POS(_route#0)) distance2D _pos;
			while {_i < _count} do {
				pr _p = __GET_POS(_route#_i);
				pr _d = _p distance2D _pos;
				if (_d < _dist) then {_dist = _d; _index = _i;};
				_i = _i + 1;
			};

			// Set pos and next index
			if (_index != (_count - 1)) then { // Select the next position, so that we don't need to drive one node backwards
				_index = _index + 1;
			};
			T_SETV("nextIdx", _index);
			T_SETV("pos", __GET_POS(_route select _index));

			// Search the route from start and delete all waypoints until this point
			_i = 0;
			pr _waypoints = T_GETV("waypoints");
			while {_i <= _index} do {
				pr _p = __GET_POS(_route#_i);
				pr _wpid = _waypoints findIf {_x isEqualTo _p};
				if (_wpid != -1) then {
					_waypoints deleteAt _wpid;
				};
				_i = _i + 1;
			};
		} else {
			// We want to set a position before it has actually been calculated
			// It's not good but probably we can just ignore this because it means we haven't gone too far away
		};
	ENDMETHOD;

	/*
	Method: getAIWaypoints
	Returns: array of waypoints for AI navigation, taking account the current position
	*/
	public METHOD(getAIWaypoints)
		params [P_THISOBJECT];
		T_GETV("waypoints")
	ENDMETHOD;

ENDCLASS;

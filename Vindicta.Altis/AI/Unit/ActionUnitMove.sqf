#include "common.hpp"

// How much time it's allowed to stand at one place without being considered 'stuck'
#define TIMER_STUCK_THRESHOLD 20

#define MOVE_WP_NAME (_thisObject + "__route_move_target")
#define MOVE_WP_DIST 200

#ifndef BUILD_RELEASE
// #define DEBUG_PF 
#endif
FIX_LINE_NUMBERS()

#define OOP_CLASS_NAME ActionUnitMove
CLASS("ActionUnitMove", "ActionUnit")

	VARIABLE("pos");
	VARIABLE("radius");
	VARIABLE("route");
	VARIABLE("remainingRoute");

	VARIABLE("lastPos");				// Used to detect if the convoy is moving
	VARIABLE("stuckTimer");
	VARIABLE("roadsToTry");				// Array with road pieces unit tried to achieve when it got stuck
	VARIABLE("stuckCounter");			// How many times this has been stuck
	VARIABLE("eventId");				// The PathCalculated event handle, we use it to detect pathfinding failure
	VARIABLE("pathingFailedCounter");	// How many times pathfinding has failed in a row, reset on success
	VARIABLE("pathingFailing");			// Set in the PathCalculated handler based on the result of the last pathfind operation

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		private _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		T_SETV("pos", _pos);

		private _radius = CALLSM3("Action", "getParameterValue", _parameters, TAG_MOVE_RADIUS, 10);
		T_SETV("radius", _radius);

		// Route can be optionally passed or not
		// We add the target position to the end
		private _route = CALLSM3("Action", "getParameterValue", _parameters, TAG_ROUTE, []) + [_pos];
		T_SETV("route", _route);

		T_SETV("lastPos", []);
	ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];

		// Handle AI just spawned state
		private _AI = T_GETV("AI");
		if(_instant) exitWith {
			private _pos = T_GETV("pos");
			T_CALLM1("teleportGroup", _pos);
			T_SETV("state", ACTION_STATE_COMPLETED);
			ACTION_STATE_COMPLETED
		};

		T_SETV("pathingFailing", false);
		T_SETV("pathingFailedCounter", 0);

		private _hO = T_GETV("hO");

		// Add pathfinding event handler, for detecting pathfinding errors (if its not already added)
		private _eventId = T_GETV("eventId");
		if(isNil "_eventId") then {
			private _eventId = [_hO, "PathCalculated", {
				params ["_agent", "_path"];
				if(count _path > 3) then {
					// Get current target position and compare with last route position to detect failure
					private _nextWP = (waypoints group _agent)#(currentWaypoint group _agent);
					private _failed = if(!isNil "_nextWP") then {
						private _endDist = waypointPosition _nextWP distance2D (_path#(count _path - 1));
						private _failed = _endDist > waypointCompletionRadius _nextWP;
						SETV(_thisArgs, "pathingFailing", _failed);
						_failed
					} else {
						false
					};
					#ifdef DEBUG_PF
					for "_i" from 0 to 1000 do {
						deleteMarker (str _agent + str _i);
					};
					{
						private _mrk = createMarker [str _agent + str _forEachIndex, _x];
						_mrk setMarkerType "mil_dot";
						if(_failed) then {
							_mrk setMarkerColor "ColorRed";
						};
						_mrk setMarkerText str _forEachIndex;
					} forEach (_this#1);
					#endif
					FIX_LINE_NUMBERS()
				};
			}, _thisObject] call CBA_fnc_addBISEventHandler;
			T_SETV("eventId", _eventId);
		};

		T_SETV("stuckTimer", GAME_TIME + TIMER_STUCK_THRESHOLD * 3);
		T_SETV("stuckCounter", 0);

		// Delete all previous waypoints
		T_CALLM0("clearWaypoints");

		private _curPos = ZERO_HEIGHT(position _hO);
		T_SETV("lastPos", _curPos);

		// regroup
		T_CALLM0("regroup");

		// Order to move
		T_CALLM0("nextWaypoint");

		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
	ENDMETHOD;
	
	METHOD(nextWaypoint)
		params [P_THISOBJECT];
		
		private _hO = T_GETV("hO");

		private _hG = group _hO;
		private _existingWPs = waypoints _hG;
		private _existingWPIdx = _existingWPs findIf { waypointName _x == MOVE_WP_NAME };

		private _remainingRoute = T_GETV("remainingRoute");
		if(isNil "_remainingRoute" || _existingWPIdx == NOT_FOUND) then {
			private _route = T_GETV("route");
			private _smallestDistance = 666666;
			private _curPos = position _hO;

			// Default to last WP
			private _closestPosIndex = count _route - 1;
			{
				private _routeWP = ZERO_HEIGHT(_x);
				private _cosAngle = if(_foreachindex + 1 < count _route) then {
					private _wpNext = ZERO_HEIGHT(_route select (_foreachindex + 1));
					(_curPos vectorFromTo _routeWP) vectorCos (_routeWP vectorFromTo _wpNext)
				} else {
					1
				};
				// Only select a route waypoint that is somewhat towards the next waypoint (i.e. don't double back just because a waypoint is closer)
				if(_cosAngle > 0.2) then {
					private _d = _routeWP distance2D _hO;
					if (_d > MOVE_WP_DIST && _d <= _smallestDistance) then {
						_smallestDistance = _d;
						_closestPosIndex = _foreachindex;
					};
				};
			} forEach _route;

			// Remaining route is all the waypoints from the closest one to the end
			_remainingRoute = _route select [_closestPosIndex, count _route];
			T_SETV("remainingRoute", _remainingRoute)
		};

		if(_existingWPIdx != NOT_FOUND) then {
			private _currWP = (_existingWPs#_existingWPIdx);
			private _currWPPos = getWPPos _currWP;
			private _newWPPos = +_currWPPos;
			while{ count _remainingRoute > 0 && { _hO distance _newWPPos < MOVE_WP_DIST } } do {
				_newWPPos = _remainingRoute deleteAt 0;
				// _currWPPos = if(count _remainingRoute > 0) then {
				//  	_remainingRoute deleteAt 0
				// } else {
				// 	T_GETV("pos")
				// };
			};
			if(!(_currWPPos isEqualTo _newWPPos)) then {
				_currWP setWPPos ZERO_HEIGHT(_newWPPos);
				T_CALLM0("regroup");
			};
			if(!(_currWP isEqualTo currentWaypoint _hG)) then {
				_hG setCurrentWaypoint _currWP;
			};
			// for "_i" from 0 to _existingWPIdx-2 do {
			// 	deleteWaypoint [_hG, 0];
			// };
		} else {
			private _nextPos = if(count _remainingRoute > 0) then {
				_remainingRoute deleteAt 0
			} else {
				T_GETV("pos")
			};
			private _wp = _hG addWaypoint [AGLToASL ZERO_HEIGHT(_nextPos), -1];
			_wp setWaypointType "MOVE";
			_wp setWaypointCompletionRadius 0;
			_wp setWaypointName MOVE_WP_NAME;
			_hG setCurrentWaypoint _wp;
			T_CALLM0("regroup");
		};
	ENDMETHOD;

	// logic to run each update-step
	METHOD(process)
		params [P_THISOBJECT];

		private _hO = T_GETV("hO");

		// Success condition: reached destination within specified radius
		if(_hO distance2D T_GETV("pos") <= T_GETV("radius")) exitWith {
			T_SETV("state", ACTION_STATE_COMPLETED);
			ACTION_STATE_COMPLETED
		};

		private _hVeh = vehicle _hO;
		private _isInVehicle = _hVeh != _hO;
		// Failure condition: unit is in a vehicle but isn't the driver of the vehicle
		if(_isInVehicle && {driver _hVeh != _hO}) exitWith {
			T_SETV("state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED
		};

		private _state = T_CALLM0("activateIfInactive");

		if(_state in [ACTION_STATE_COMPLETED, ACTION_STATE_FAILED]) exitWith {
			T_SETV("state", _state);
			_state
		};

		private _AI = T_GETV("AI");

		T_CALLM0("nextWaypoint");

		// Not moving
		private _lastPos = T_GETV("lastPos");
		if (!(_lastPos isEqualTo []) && {_lastPos distance2D _hO < 0.1}) then {
			private _stuckTimer = T_GETV("stuckTimer");

			OOP_WARNING_1("Unit is probably stuck: %1", _stuckTimer);

			if (GAME_TIME > _stuckTimer) then {
				OOP_WARNING_0("Unit is totally stuck now!");

				private _stuckCounter = T_GETV("stuckCounter");

				private _pathingFailing = T_GETV("pathingFailing");
				private _pathingFailedCounter = T_GETV("pathingFailedCounter");
				if(_pathingFailing) then {
					T_SETV("pathingFailedCounter", _pathingFailedCounter + 1);
				} else {
					T_SETV("pathingFailedCounter", 0);
				};

				switch true do {
					case (_stuckCounter < 3): {
						T_CALLM0("regroup");
						_hO doMove getWPPos (waypoints group _hO select currentWaypoint group _hO);
						T_SETV("stuckTimer", GAME_TIME + TIMER_STUCK_THRESHOLD);
					};
					case (_stuckCounter < 5): {
						T_CALLM0("clearWaypoints");
						T_SETV("stuckTimer", GAME_TIME + TIMER_STUCK_THRESHOLD);
					};
					case (_stuckCounter < 10): {
						// Let's try to teleport you somewhere >_<
						OOP_WARNING_0("Teleporting the Unit!");
						private _defaultPos = position _hVeh;
						private _newPos = if(_isInVehicle) then {
							[_defaultPos, 0, 100, 7, 0, 100, 0, [], [_defaultPos, _defaultPos]] call BIS_fnc_findSafePos;
						} else {
							[_defaultPos, 0, 100, 0, 0, 100, 0, [], [_defaultPos, _defaultPos]] call BIS_fnc_findSafePos;
						};
						_hVeh setPos _newPos;
						T_SETV("stuckTimer", GAME_TIME + TIMER_STUCK_THRESHOLD * 3);
					};
					default {
						// We failed with routing to the first waypoint, lets mark it as bad in our world facts for a while
						if(_pathingFailedCounter > 5) then {
							private _wf = WF_NEW();
							[_wf, WF_TYPE_UNIT_UNPATHABLE] call wf_fnc_setType;
							[_wf, 300] call wf_fnc_setLifetime;
							[_wf, waypointPosition ((waypoints group _hO)#0)] call wf_fnc_setPos;
							CALLM1(_AI, "addWorldFact", _wf);
						};
						_state = ACTION_STATE_FAILED;
						T_SETV("stuckTimer", GAME_TIME + TIMER_STUCK_THRESHOLD);
					};
				};
				T_SETV("stuckCounter", _stuckCounter + 1);
			};
		} else {
			// Reset the timer
			T_SETV("stuckTimer", GAME_TIME + TIMER_STUCK_THRESHOLD * 3);
			T_SETV("stuckCounter", 0);
		};

		T_SETV("lastPos", position _hO);
		T_SETV("state", _state);
		_state
	ENDMETHOD;
	
	// logic to run when the goal is about to be terminated
	METHOD(terminate)
		params [P_THISOBJECT];

		// Delete waypoints
		T_CALLM0("clearWaypoints");

		// Stop the unit
		private _hO = T_GETV("hO");
		doStop _hO;

		// Remove the pathfinding event handler
		private _eventId = T_GETV("eventId");
		if(!isNil "_eventId") then {
			_hO removeEventHandler["PathCalculated", _eventId];
		};
	ENDMETHOD;

ENDCLASS;
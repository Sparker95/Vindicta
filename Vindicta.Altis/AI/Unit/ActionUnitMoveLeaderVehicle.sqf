#include "common.hpp"

/*
Should be used for a vehicle driver that drives the lead vehicle of a convoy.
Parameters: TAG_POS - position where to move to
Author: Sparker 13.02.2019
*/

#define pr private

// How much time it's allowed to stand at one place without being considered 'stuck'
#define TIMER_STUCK_THRESHOLD 20

#define MOVE_WP_NAME "__route_move_target"
#define MOVE_WP_DIST 200

#define DEBUG_PF 

CLASS("ActionUnitMoveLeaderVehicle", "ActionUnit")
	
	VARIABLE("pos");
	VARIABLE("radius");
	VARIABLE("route");
	VARIABLE("remainingRoute");

	VARIABLE("lastPos"); // Used to detect if the convoy is moving
	VARIABLE("stuckTimer");
	VARIABLE("roadsToTry"); // Array with road pieces unit tried to achieve when it got stuck
	VARIABLE("stuckCounter"); // How many times this has been stuck
	VARIABLE("eventId"); // The PathCalculated event handle, we use it to detect pathfinding failure
	VARIABLE("pathingFailedCounter"); // How many times pathfinding has failed in a row, reset on success
	VARIABLE("pathingFailing"); // Set in the PathCalculated handler based on the result of the last pathfind operation

	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		pr _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		T_SETV("pos", _pos);

		pr _radius = CALLSM3("Action", "getParameterValue", _parameters, TAG_MOVE_RADIUS, 10);
		T_SETV("radius", _radius);

		// Route can be optionally passed or not
		// We add the target position to the end
		pr _route = CALLSM3("Action", "getParameterValue", _parameters, TAG_ROUTE, []) + [_pos];
		T_SETV("route", _route);

		T_SETV("lastPos", []);

	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [P_THISOBJECT];
		
		// Handle AI just spawned state
		pr _AI = T_GETV("AI");
		if (GETV(_AI, "new")) then {
			SETV(_AI, "new", false);
		};

		T_SETV("pathingFailing", false);
		T_SETV("pathingFailedCounter", 0);

		pr _hO = T_GETV("hO");

		// Add pathfinding event handler, for detecting pathfinding errors (if its not already added)
		pr _eventId = T_GETV("eventId");
		if(isNil "_eventId") then {
			pr _eventId = [_hO, "PathCalculated", {
				params ["_agent", "_path"];
				if(count _path > 3) then {
					// Get current target position and compare with last route position to detect failure
					pr _nextWP = (waypoints group _agent)#(currentWaypoint group _agent);
					pr _failed = if(!isNil "_nextWP") then {
						pr _endDist = waypointPosition _nextWP distance2D (_path#(count _path - 1));
						pr _failed = _endDist > waypointCompletionRadius _nextWP;
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
						pr _mrk = createMarker [str _agent + str _forEachIndex, _x];
						_mrk setMarkerType "mil_dot";
						if(_failed) then {
							_mrk setMarkerColor "ColorRed";
						};
						_mrk setMarkerText str _forEachIndex;
					} forEach (_this#1);
					#endif
				};
			}, _thisObject] call CBA_fnc_addBISEventHandler;
			T_SETV("eventId", _eventId);
		};

		T_SETV("stuckTimer", TIME_NOW + TIMER_STUCK_THRESHOLD);
		T_SETV("roadsToTry", []);
		T_SETV("stuckCounter", 0);

		// Delete all previous waypoints
		T_CALLM0("clearWaypoints");

		pr _curPos = ZERO_HEIGHT(position _hO);
		T_SETV("lastPos", _curPos);

		// regroup
		T_CALLM0("regroup");

		// Order to move
		T_CALLM0("nextWaypoint");

		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	METHOD("nextWaypoint") {
		params [P_THISOBJECT];
		
		pr _hO = T_GETV("hO");
		pr _pos = T_GETV("pos");

		pr _hG = group _hO;
		pr _existingWPs = waypoints _hG;
		pr _existingWPIdx = _existingWPs findIf { waypointName _x == MOVE_WP_NAME };

		pr _remainingRoute = T_GETV("remainingRoute");
		if(isNil "_remainingRoute" || _existingWPIdx == NOT_FOUND) then {
			pr _route = T_GETV("route");
			pr _smallestDistance = 666666;
			pr _curPos = position _hO;

			// Default to last WP
			pr _closestPosIndex = count _route - 1;
			{
				pr _routeWP = ZERO_HEIGHT(_x);
				pr _cosAngle = if(_foreachindex + 1 < count _route) then {
					pr _wpNext = ZERO_HEIGHT(_route select (_foreachindex + 1));
					(_curPos vectorFromTo _routeWP) vectorCos (_routeWP vectorFromTo _wpNext)
				} else {
					1
				};
				// Only select a route waypoint that is somewhat towards the next waypoint (i.e. don't double back just because a waypoint is closer)
				if(_cosAngle > 0.2) then {
					pr _d = _routeWP distance2D _hO;
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

		if(count _remainingRoute > 0) then {
			if(_existingWPIdx != NOT_FOUND) then {
				pr _currWP = (_existingWPs#_existingWPIdx);
				if(_hO distance getWPPos _currWP < MOVE_WP_DIST) then {
					pr _nextPos = _remainingRoute deleteAt 0;
					(_existingWPs#_existingWPIdx) setWPPos ZERO_HEIGHT(_nextPos);
				};
			} else {
				pr _nextPos = _remainingRoute deleteAt 0;
				pr _wp = _hG addWaypoint [ZERO_HEIGHT(_nextPos), 0];
				_wp setWaypointType "MOVE";
				_wp setWaypointCompletionRadius 0;
				_wp setWaypointName MOVE_WP_NAME;
				_hG setCurrentWaypoint _wp;
			};
		};

		// Give waypoints to move
		//pr _waypoints = [];

		// // Find the closest waypoint
		// // We don't want to re-add all waypoints, but we want to start from the closest one which is forward
		// // of our current position. Forward can be defined as <90 degree angle made by the unit position,
		// // the waypoint, and the next waypoint after it.
		// pr _wpPositions = _route + [_pos];
		// pr _startPos = ZERO_HEIGHT(position _hO);
		// {
		// 	pr _wpCurr = ZERO_HEIGHT(_x);
		// 	pr _cosAngle = if(_foreachindex + 1 < count _wpPositions) then {
		// 		pr _wpNext = ZERO_HEIGHT(_wpPositions select (_foreachindex + 1));
		// 		(_startPos vectorFromTo _wpCurr) vectorCos (_wpCurr vectorFromTo _wpNext)
		// 	} else {
		// 		1
		// 	};
		// 	if(_cosAngle > 0) then {
		// 		pr _d = _wpCurr distance2D _hO;
		// 		if (_d <= _smallestDistance) then {
		// 			_smallestDistance = _d;
		// 			_closestPosIndex = _foreachindex;
		// 		};
		// 	};
		// } forEach _wpPositions;

		// pr _hG = group _hO;

		// // Add waypoints starting from closest one
		// for "_i" from _closestPosIndex to ((count _wpPositions) - 1) do {
		// 	pr _x = _wpPositions#_i;
		// 	pr _wp = _hG addWaypoint [ZERO_HEIGHT(_x), 0];
		// 	_wp setWaypointType "MOVE";
		// 	//_wp setWaypointFormation "COLUMN";
		// 	//_wp setWaypointBehaviour "SAFE";
		// 	//_wp setWaypointCombatMode "GREEN";
		// 	_wp setWaypointCompletionRadius 100;
		// 	_waypoints pushBack _wp;
		// };

		// (_waypoints#(count _waypoints - 1)) setWaypointCompletionRadius T_GETV("radius");

		// _hG setCurrentWaypoint ((waypoints _hG)#0);

	} ENDMETHOD;

	// logic to run each update-step
	METHOD("process") {
		params [P_THISOBJECT];

		pr _hO = T_GETV("hO");
		//pr _hG = group _hO;
		//pr _wps = waypoints _hG;

		if(_hO distance2D T_GETV("pos") <= T_GETV("radius")) exitWith {
			T_SETV("state", ACTION_STATE_COMPLETED);
			ACTION_STATE_COMPLETED
		};

		// Driver dismounted so we failed
		if(vehicle _hO == _hO) exitWith {
			T_SETV("state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED
		};

		//pr _nextWP = _wps#(currentWaypoint _hG);

		//private _hG = group _hO;

		// Make sure we are always targetting the first waypoint (waypoints can get added)
		//_hG setCurrentWaypoint ((waypoints _hG)#0);

		pr _state = T_CALLM0("activateIfInactive");
		pr _AI = T_GETV("AI");

		T_CALLM0("nextWaypoint");

		// Not moving
		if (T_GETV("lastPos") distance2D _hO < 0.1) then {
			pr _stuckTimer = T_GETV("stuckTimer");

			OOP_WARNING_1("Leader vehicle is probably stuck: %1", _stuckTimer);

			if (TIME_NOW > _stuckTimer) then {
				OOP_WARNING_0("Is totally stuck now!");

				pr _stuckCounter = T_GETV("stuckCounter");

				pr _pathingFailing = T_GETV("pathingFailing");
				pr _pathingFailedCounter = T_GETV("pathingFailedCounter");
				if(_pathingFailing) then {
					T_SETV("pathingFailedCounter", _pathingFailedCounter + 1);
				} else {
					T_SETV("pathingFailedCounter", 0);
				};

				// give it a bump
				private _pushdir = 0;
				// vehicle is stuck
				if ((lineintersectssurfaces [_hO modeltoworldworld [0,0,0.2], _hO modeltoworldworld [0,8,0.2], _hO]) isEqualTo []) then {
					//push it forwards a little
					_pushdir = 5;
				} else {
					// if there's something in front, push backwards, not forwards
					_pushdir = -5;
				};
				_hO setVelocityModelSpace [0, _pushdir, 0];

				// pr _hG = group _hO;
				// pr _nextWp = (waypoints _hG)#0;
				// pr _hVeh = vehicle _hO;
				// _hVeh setDir ((getDir _hVeh) + 180);
				// _hVeh setPosWorld ((getPosWorld _hVeh) vectorAdd [0, 0, 1]);

				switch true do {
					case (_stuckCounter < 3): {
						//T_CALLM0("addWaypoints");
						// pr _mass = getMass _hO;
						// _hO addForce [[0, 0, _mass*(4+random 2)], getCenterOfMass _hO];
						// T_CALLM0("regroup");

						// Add an extra intermediate waypoint closer to the vehicle, preferably on the road
						// pr _roadsToTry = T_GETV("roadsToTry");
						// if(_roadsToTry isEqualTo []) then {
						// 	pr _nr = ((_hO nearRoads 50) - (_hO nearRoads 25)) apply { [_x distance2D _hO, _x] };
						// 	_nr sort ASCENDING;
						// 	_roadsToTry append (_nr apply { _x#1 });
						// };
						// pr _wppos = if (count _roadsToTry > 0) then {
						// 	position (_roadsToTry deleteAt 0)
						// } else {
						// 	[vehicle _hO, 25, 50, 3, 0, 100, 0, [], position _hO] call BIS_fnc_findSafePos;
						// };
						// pr _wppos = position _hO;
						// pr _hG = group _hO;
						// pr _nextWp = (waypoints _hG)#0;
						// if(waypointName _nextWp isEqualTo "kickintheass") then {
						// 	deleteWaypoint _nextWp;
						// };
						// pr _wp = _hG addWaypoint [_wppos, 4, 0, "kickintheass"];
						// _wp setWaypointCompletionRadius 10;
						// _hG setCurrentWaypoint ((waypoints _hG)#0);

						//OOP_WARNING_0("Moving the leader vehicle to the nearest road...");
						// do move to the nearest road piece we didn't visit yet

						// // Regroup and force correct facing direction
						// pr _currDir =  vehicle _hO;
						// pr _nextWPDir = 
						T_CALLM0("regroup");
						T_SETV("stuckTimer", TIME_NOW + TIMER_STUCK_THRESHOLD);
					};
					case (_stuckCounter < 5): {
						// Reset route
						T_CALLM0("clearWaypoints");
						T_SETV("stuckTimer", TIME_NOW + TIMER_STUCK_THRESHOLD * 3);
					};
					// case (_stuckCounter < 10): {
					// 	// Try to doMove to some of the nearest roads
					// 	pr _roadsToTry = T_GETV("roadsToTry");
					// 	if(_roadsToTry isEqualTo []) then {
					// 		pr _nr = ((_hO nearRoads 200) - (_hO nearRoads 25)) apply { [_x distance2D _hO, _x] };
					// 		_nr sort ASCENDING;
					// 		_roadsToTry append (_nr apply { _x#1 });
					// 	};
					// 	if (count _roadsToTry > 0) then {
					// 		OOP_WARNING_0("Moving the leader vehicle to the nearest road...");

					// 		// do move to the nearest road piece we didn't visit yet
					// 		pr _road = _roadsToTry deleteAt 0;
					// 		_hO doMove (getPos _road);
					// 		T_CALLM0("regroup");
					// 	};
					// 	T_SETV("stuckTimer", TIME_NOW + TIMER_STUCK_THRESHOLD * 3);
					// };
					// case _stuckCounter < 15: {
					// 	OOP_WARNING_0("Tried to move to nearest road too many times!");
					// 	// Allright this shit is serious
					// 	// We need serious measures now :/
					// 	OOP_WARNING_0("Rotating the leader vehicle!");
					// 	// Let's just try to rotate you?
					// 	pr _hVeh = vehicle _hO;
					// 	_hVeh setDir ((getDir _hVeh) + 180);
					// 	_hVeh setPosWorld ((getPosWorld _hVeh) vectorAdd [0, 0, 1]);
					// 	T_CALLM0("regroup");
					// };
					case (_stuckCounter < 10): {
						// Let's try to teleport you somewhere >_<
						OOP_WARNING_0("Teleporting the leader vehicle!");
						pr _hVeh = vehicle _hO;
						pr _defaultPos = getPos _hVeh;
						pr _newPos = [_hVeh, 0, 100, 7, 0, 100, 0, [], [_defaultPos, _defaultPos]] call BIS_fnc_findSafePos;
						_hVeh setPos _newPos;
						//T_CALLM0("regroup");
						T_SETV("stuckTimer", TIME_NOW + TIMER_STUCK_THRESHOLD * 3);
					};
					// default {
					// 	// If finally it doesn't want to move, make driver dismount, so that actions are regenerated and he is made to mount the vehicle again
					// 	CALLM0(_AI, "unassignVehicle"); // Fuck this shit
					// 	T_CALLM0("regroup");
					// 	_stuckCounter = 0;
					// };
					default {
						// We failed with routing to the first waypoint, lets mark it as bad in our world facts for a while
						if(_pathingFailedCounter > 5) then {
							pr _wf = WF_NEW();
							[_wf, WF_TYPE_UNIT_UNPATHABLE] call wf_fnc_setType;
							[_wf, 300] call wf_fnc_setLifetime;
							[_wf, waypointPosition ((waypoints group _hO)#0)] call wf_fnc_setPos;
							CALLM1(_AI, "addWorldFact", _wf);
						};
						_state = ACTION_STATE_FAILED;
						T_SETV("stuckTimer", TIME_NOW + TIMER_STUCK_THRESHOLD);
					};
				};

				// T_SETV("readdwp", true);
				T_SETV("stuckCounter", _stuckCounter + 1);
			};
		} else {
			// Reset the timer
			T_SETV("stuckTimer", TIME_NOW + TIMER_STUCK_THRESHOLD);
			T_SETV("stuckCounter", 0);
			T_SETV("roadsToTry", []);
		};

		T_SETV("lastPos", position _hO);
		T_SETV("state", _state);
		_state
	} ENDMETHOD;
	
	// logic to run when the goal is about to be terminated
	METHOD("terminate") {
		params [P_THISOBJECT];

		// Delete waypoints
		T_CALLM0("clearWaypoints");

		// Stop the car from driving around
		pr _hO = T_GETV("hO");
		doStop _hO;

		// Remove the pathfinding event handler
		pr _eventId = T_GETV("eventId");
		if(!isNil "_eventId") then {
			_hO removeEventHandler["PathCalculated", _eventId];
		};
	} ENDMETHOD; 

ENDCLASS;
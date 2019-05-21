#include "common.hpp"

/*
Should be used for a vehicle driver that drives the lead vehicle of a convoy.
Parameters: TAG_POS - position where to move to
Author: Sparker 13.02.2019
*/

#define pr private

// How much time it's allowed to stand at one place without being considered 'stuck'
#define TIMER_STUCK_THRESHOLD 30

CLASS("ActionUnitMoveLeaderVehicle", "ActionUnit")
	
	VARIABLE("pos");
	VARIABLE("stuckTimer");
	VARIABLE("time");
	VARIABLE("triedRoads"); // Array with road pieces unit tried to achieve when it got stuck
	VARIABLE("stuckCounter"); // How many times this has been stuck
	VARIABLE("readdwp");
	
	// ------------ N E W ------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], []] ];
		
		pr _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		T_SETV("pos", _pos);
		
		// Route can be optionally passed or not
		pr _route = CALLSM2("Action", "getParameterValue", _parameters, TAG_ROUTE);
		if (isNil "_route") then {
			_route = [];
		};
		T_SETV("route", _route);

		T_SETV("readdwp", false);
		
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];
		
		// Handle AI just spawned state
		pr _AI = T_GETV("AI");
		if (GETV(_AI, "new")) then {
			SETV(_AI, "new", false);
		};

		T_SETV("stuckTimer", TIMER_STUCK_THRESHOLD-4);
		T_SETV("time", time);
		T_SETV("triedRoads", []);
		T_SETV("stuckCounter", 0);
		
		pr _hO = GETV(_thisObject, "hO");
		pr _hG = group _hO;
		
		// Order to move
		CALLM0(_thisObject, "addWaypoints");
		
		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	METHOD("addWaypoints") {
		params ["_thisObject"];
		
		pr _hO = GETV(_thisObject, "hO");
		pr _hG = group _hO;
		pr _pos = T_GETV("pos");
		
		// Delete all previous waypoints
		while {(count (waypoints _hG)) > 0} do { deleteWaypoint ((waypoints _hG) select 0); };
		
		// Give waypoints to move
		pr _waypoints = [];
		pr _route = T_GETV("route");
		{
			pr _wp = _hG addWaypoint [_pos, 0];
			_wp setWaypointType "MOVE";
			_wp setWaypointFormation "COLUMN";
			_wp setWaypointBehaviour "SAFE";
			_wp setWaypointCombatMode "GREEN";
			_waypoints pushBack _wp;
		} forEach (_route + [_pos]);
		_hG setCurrentWaypoint (_waypoints select 0);

		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		pr _state = CALLM0(_thisObject, "activateIfInactive");
		
		pr _hO = GETV(_thisObject, "hO");
		pr _dt = time - T_GETV("time"); // Time that has passed since previous call
		
		if (T_GETV("readdwp")) then {
			CALLM0(_thisObject, "addWaypoints");
			T_SETV("readdwp", false);
		};
		
		// My speed is small AF
		if (speed _hO < 4) then {
			pr _timer = T_GETV("stuckTimer");
			_timer = _timer + _dt;
			T_SETV("stuckTimer", _timer);
			
			OOP_WARNING_1("Leader vehicle is probably stuck: %1", _timer);
			
			if (_timer > TIMER_STUCK_THRESHOLD) then {
				OOP_WARNING_0("Is totally stuck now!");
				
				pr _stuckCounter = T_GETV("stuckCounter");
				
				if (_stuckCounter < 3) then {
					// Try to doMove to some of the nearest roads
					pr _triedRoads = T_GETV("triedRoads");
					pr _nr = (_ho nearRoads 200) select {! (_x in _triedRoads)};
					if (count _nr > 0) then {
						OOP_WARNING_0("Moving the leader vehicle to the nearest road...");
					
						// Sort roads by distance
						_nr = (_nr apply {[_x, _x distance2D _hO]});
						_nr sort true; // Ascending
						
						// do move to the nearest road piece we didn't visit yet
						pr _road = (_nr select 0) select 0;
						_hO doMove (getpos _road);
						_triedRoads pushBack _road;
					};
				} else {
					OOP_WARNING_0("Tried to move to nearest road too many times!");
					// Allright this shit is serious
					// We need serious measures now :/
					if (_stuckCounter < 5) then {
						OOP_WARNING_0("Rotating the leader vehicle!");
						// Let's just try to rotate you?
						pr _hVeh = vehicle _hO;
						_hVeh setDir ((getDir _hVeh) + 180);
						_hVeh setPosWorld ((getPosWorld _hVeh) vectorAdd [0, 0, 1]);
					} else {
						// Let's try to teleport you somewhere >_<
						OOP_WARNING_0("Teleporting the leader vehicle!");
						pr _hVeh = vehicle _hO;
						pr _defaultPos = getPos _hVeh;
						pr _newPos = [_hVeh, 0, 100, 7, 0, 100, 0, [], [_defaultPos, _defaultPos]] call BIS_fnc_findSafePos;
						_hVeh setPos _newPos;
					};

					
				};
				
				T_SETV("readdwp", true);
				T_SETV("stuckTimer", 0);
				T_SETV("stuckCounter", _stuckCounter + 1);
			};
		} else {
			// Reset the timer
			T_SETV("stuckTimer", 0);
		};
		
		T_SETV("time", time);
		
		T_SETV("state", _state);
		_state
	} ENDMETHOD;
	
	// logic to run when the goal is about to be terminated
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		// Stop the car from driving around
		pr _hO = GETV(_thisObject, "hO");
		doStop _hO;
	} ENDMETHOD; 

ENDCLASS;
#include "common.hpp"

/*
Should be used for a vehicle driver that must follow the lead vehicle in a convoy.
Author: Sparker 13.02.2019
*/

#define pr private

// How much time it's allowed to stand at one place without being considered 'stuck'
#define TIMER_STUCK_THRESHOLD 50

CLASS("ActionUnitFollowLeaderVehicle", "ActionUnit")
	
	VARIABLE("dist"); // Distance to leader's vehicle
	VARIABLE("stuckTimer");
	VARIABLE("time");
	VARIABLE("triedRoads"); // Array with road pieces unit tried to achieve when it got stuck
	VARIABLE("stuckCounter"); // How many times this has been stuck
	
	// ------------ N E W ------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]] ];
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];
		
		pr _hO = GETV(_thisObject, "hO");
		
		// Order to follow leader
		_hO doFollow (leader group _hO);
		
		// Get distance between the vehicle of this unit and the lead vehicle
		pr _dist = (vehicle _hO) distance (vehicle leader group _hO);
		T_SETV("dist", _dist);
		T_SETV("stuckTimer", 0);
		T_SETV("time", time);
		T_SETV("triedRoads", []);
		T_SETV("stuckCounter", 0);
		
		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		pr _state = CALLM(_thisObject, "activateIfInactive", []);
		
		pr _hO = GETV(_thisObject, "hO");
		pr _dist = (vehicle _hO) distance (vehicle leader group _hO);
		pr _distPrev = T_GETV("dist");
		pr _dt = time - T_GETV("time"); // Time that has passed since previous call
		
		// Distance is increasing and my speed is small AF
		if ((_dist >= _distPrev) && (speed _hO < 4)) then {
			pr _timer = T_GETV("stuckTimer");
			_timer = _timer + _dt;
			T_SETV("stuckTimer", _timer);
			
			OOP_WARNING_1("Probably stuck: %1", _timer);
			
			if (_timer > TIMER_STUCK_THRESHOLD) then {
				OOP_WARNING_0("Is totally stuck now!");
				
				pr _stuckCounter = T_GETV("stuckCounter");
				
				if (_stuckCounter < 3) then {
					// Try to doMove to some of the nearest roads
					pr _triedRoads = T_GETV("triedRoads");
					pr _nr = (_ho nearRoads 200) select {! (_x in _triedRoads)};
					if (count _nr > 0) then {
						OOP_WARNING_0("Moving to nearest road...");
						// Sort roads by distance
						_nr = (_nr apply {[_x, _x distance2D _hO]});
						_nr sort true; // Ascending
						
						// do move to the nearest road piece we didn't visit yet
						pr _road = (_nr select 0) select 0;
						_hO doMove (getpos _road);
						_triedRoads pushBack _road;
					};
				} else {
					// Allright this shit is serious
					// We need serious measures now :/
					if (_stuckCounter < 4) then {
						OOP_WARNING_0("Rotating the vehicle!");
						// Let's just try to rotate you?
						pr _hVeh = vehicle _hO;
						_hVeh setDir ((getDir _hVeh) + 180);
						_hVeh setPosWorld ((getPosWorld _hVeh) vectorAdd [0, 0, 1]);
					} else {
						// Let's try to teleport you somewhere >_<
						OOP_WARNING_0("Teleporting the vehicle!");
						pr _hVeh = vehicle _hO;
						pr _defaultPos = getPos _hVeh;
						pr _newPos = [_hVeh, 0, 100, 7, 0, 100, 0, [], [_defaultPos, _defaultPos]] call BIS_fnc_findSafePos;
						_hVeh setPos _newPos;
					};
				};				
				
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
	
	// logic to run when the goal is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		// Stop the car from driving around
		pr _hO = GETV(_thisObject, "hO");
		doStop _hO;
	} ENDMETHOD; 

ENDCLASS;
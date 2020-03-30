#include "common.hpp"

/*
Should be used for a vehicle driver that must follow the lead vehicle in a convoy.
Author: Sparker 13.02.2019
*/

#define pr private

// How much time it's allowed to stand at one place without being considered 'stuck'
#define TIMER_STUCK_THRESHOLD 20

CLASS("ActionUnitFollowLeaderVehicle", "ActionUnit")

	VARIABLE("dist"); // Distance to leader's vehicle
	VARIABLE("stuckTimer");
	//VARIABLE("time");
	//VARIABLE("triedRoads"); // Array with road pieces unit tried to achieve when it got stuck
	VARIABLE("stuckCounter"); // How many times this has been stuck

	// logic to run when the goal is activated
	METHOD("activate") {
		params [P_THISOBJECT];

		// Handle AI just spawned state
		pr _AI = T_GETV("AI");
		if (GETV(_AI, "new")) then {
			SETV(_AI, "new", false);
		};

		pr _hO = GETV(_thisObject, "hO");

		// Order to follow leader
		_hO doFollow (leader group _hO);

		// Get distance between the vehicle of this unit and the lead vehicle
		pr _dist = (vehicle _hO) distance (vehicle leader group _hO);
		T_SETV("dist", _dist);
		T_SETV("stuckTimer", TIME_NOW + TIMER_STUCK_THRESHOLD * 3);
		//T_SETV("triedRoads", []);
		T_SETV("stuckCounter", 0);

		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
	} ENDMETHOD;

	// logic to run each update-step
	METHOD("process") {
		params [P_THISOBJECT];

		pr _state = CALLM0(_thisObject, "activateIfInactive");

		pr _hO = GETV(_thisObject, "hO");
		pr _dist = (vehicle _hO) distance (vehicle leader group _hO);
		pr _distPrev = T_GETV("dist");

		// Distance is increasing and my speed is small AF
		if ((_dist >= _distPrev) && (speed _hO < 4)) then {
			pr _stuckTimer = T_GETV("stuckTimer");

			if (TIME_NOW > _stuckTimer) then {
				OOP_WARNING_0("Is totally stuck now!");

				pr _stuckCounter = T_GETV("stuckCounter");
				switch true do {
					case (_stuckCounter < 20): {
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
						_hO doFollow leader _hO;
						
						T_SETV("stuckTimer", TIME_NOW + TIMER_STUCK_THRESHOLD / 2);
					};
					case (_stuckCounter < 6): {
						// Try to doMove to some of the leader
						_hO doFollow leader _hO;
						_hO doMove (position leader _hO);

						T_SETV("stuckTimer", TIME_NOW + TIMER_STUCK_THRESHOLD);
					};
					default {
						// Teleport to leader
						OOP_WARNING_0("Teleporting the vehicle!");
						pr _leadVehicle = vehicle leader _hO;
						pr _defaultPos = position _leadVehicle vectorAdd (_leadVehicle modeltoworldworld [0, -25, 0]);
						pr _hVeh = vehicle _hO;
						pr _newPos = [_hVeh, 0, 50, 7, 0, 100, 0, [], [_defaultPos, _defaultPos]] call BIS_fnc_findSafePos;
						_hVeh setPos _newPos;
						_hVeh setDir direction _leadVehicle;
						_hO doFollow leader _hO;

						// Reset stuck counter
						T_SETV("stuckTimer", TIME_NOW + TIMER_STUCK_THRESHOLD * 3);
						_stuckCounter = -1;
					};
				};

				// if (_stuckCounter < 3) then {
				// } else {
				// 	// Allright this shit is serious
				// 	// We need serious measures now :/
				// 	if (_stuckCounter < 4) then {
				// 		OOP_WARNING_0("Rotating the vehicle!");
				// 		// Let's just try to rotate you?
				// 		pr _hVeh = vehicle _hO;
				// 		_hVeh setDir ((getDir _hVeh) + 180);
				// 		_hVeh setPosWorld ((getPosWorld _hVeh) vectorAdd [0, 0, 1]);
				// 	} else {
				// 		// Let's try to teleport you somewhere >_<
				// 		OOP_WARNING_0("Teleporting the vehicle!");
				// 		pr _hVeh = vehicle _hO;
				// 		pr _defaultPos = getPos _hVeh;
				// 		pr _newPos = [_hVeh, 0, 100, 7, 0, 100, 0, [], [_defaultPos, _defaultPos]] call BIS_fnc_findSafePos;
				// 		_hVeh setPos _newPos;
				// 	};
				// };

				//T_SETV("stuckTimer", 0);
				T_SETV("stuckCounter", _stuckCounter + 1);
			};
		}else {
			// Reset the timer
			T_SETV("stuckTimer", TIME_NOW + TIMER_STUCK_THRESHOLD * 3);
			T_SETV("stuckCounter", 0);
		};

		T_SETV("time", time);

		T_SETV("state", _state);
		_state
	} ENDMETHOD;
	
	// logic to run when the goal is satisfied
	METHOD("terminate") {
		params [P_THISOBJECT];
		
		// Stop the car from driving around
		pr _hO = GETV(_thisObject, "hO");
		doStop _hO;
	} ENDMETHOD; 

ENDCLASS;
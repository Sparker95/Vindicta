#include "common.hpp"

/*
Should be used for a vehicle driver that must follow the lead vehicle in a convoy.
Author: Sparker 13.02.2019
*/

#define pr private

// How much time it's allowed to stand at one place without being considered 'stuck'
#define TIMER_STUCK_THRESHOLD 30

#define SEPARATION 18

CLASS("ActionUnitFollowLeaderVehicle", "ActionUnit")

	VARIABLE("expectedDistance");
	VARIABLE("lastPos");
	VARIABLE("stuckTimer");
	VARIABLE("stuckCounter");

	// logic to run when the goal is activated
	METHOD("activate") {
		params [P_THISOBJECT];

		pr _hO = T_GETV("hO");

		// Order to follow leader
		_hO stop false;
		_hO doFollow (leader group _hO);

		// Get unit index in drivers list to determine expected distance we should be from the leader 
		pr _index = 1 max (units group _hO select { vehicle _x != _x && { driver vehicle _x == _x } } find { _hO });
		T_SETV("expectedDistance", SEPARATION * _index);
		T_SETV("stuckTimer", TIME_NOW + TIMER_STUCK_THRESHOLD);
		T_SETV("lastPos", position _hO);
		T_SETV("stuckCounter", 0);

		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
	} ENDMETHOD;

	// logic to run each update-step
	METHOD("process") {
		params [P_THISOBJECT];

		pr _state = T_CALLM0("activateIfInactive");

		pr _hO = T_GETV("hO");

		private _hVeh = vehicle _hO;

		// Driver dismounted so we failed
		if(_hVeh == _hO) exitWith {
			T_SETV("state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED
		};

		// This action isn't valid on leader
		if(leader _hO == _hO) exitWith {
			T_SETV("state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED
		};

		// This action only works on driver of vehicle
		if(driver _hVeh != _hO) exitWith {
			T_SETV("state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED
		};

		//pr _dist = _hVeh distance (vehicle leader _hO);
		//pr _distPrev = T_GETV("dist");

		// Distance is increasing and my speed is small AF
		//if ((_dist >= _distPrev) && (speed _hVeh < 4)) then {
		pr _timer = T_GETV("stuckTimer");

		if (TIME_NOW > _timer) then {
			pr _lastPos = T_GETV("lastPos");
			T_SETV("lastPos", position _hVeh);
			pr _leadVehicle = vehicle leader _hO;
			pr _expectedDistance = T_GETV("expectedDistance");
			// Are we making progress?
			if(_lastPos distance2D _hVeh < TIMER_STUCK_THRESHOLD && _hVeh distance2D _leadVehicle > T_GETV("expectedDistance") * 2) then {
				// give it a bump
				private _pushdir = 0;
				
				// vehicle is stuck
				if ((lineintersectssurfaces [_hVeh modeltoworldworld [0,0,0.2], _hVeh modeltoworldworld [0,8,0.2], _hVeh]) isEqualTo []) then {
					//push it forwards a little
					_pushdir = 5;
				} else {
					// if there's something in front, push backwards, not forwards
					_pushdir = -5;
				};
				_hVeh setVelocityModelSpace [0, _pushdir, 0];
				_hO doFollow leader _hO;

				pr _stuckCounter = T_GETV("stuckCounter");
				switch true do {
					case (_stuckCounter > 3 && _stuckCounter <= 6): {
						// Try to doMove to position of the leader
						_hO doMove (position leader _hO);
					};
					case (_stuckCounter > 6): {
						// Teleport to leader
						pr _defaultPos = position _leadVehicle vectorAdd (_leadVehicle modeltoworldworld [0, -_expectedDistance, 0]);
						pr _newPos = [_hVeh, 0, 50, 7, 0, 100, 0, [], [_defaultPos, _defaultPos]] call BIS_fnc_findSafePos;
						_hVeh setPos _newPos;
						_hVeh setDir direction _leadVehicle;
						_hO doFollow leader _hO;

						// Reset stuck counter
						_stuckCounter = -1;
					};
				};
				T_SETV("stuckCounter", _stuckCounter + 1);
			};
			T_SETV("stuckTimer", TIME_NOW + TIMER_STUCK_THRESHOLD);
		};
		//  }else {
		// 	// Reset the timer
		// 	T_SETV("stuckTimer", TIME_NOW + TIMER_STUCK_THRESHOLD * 3);
		// 	T_SETV("stuckCounter", 0);
		// };

		//T_SETV("dist", _dist);
		//T_SETV("time", time);

		T_SETV("state", _state);
		_state
	} ENDMETHOD;
	
	// logic to run when the goal is satisfied
	METHOD("terminate") {
		params [P_THISOBJECT];
		
		// Stop the car from driving around
		pr _hO = T_GETV("hO");
		doStop _hO;
	} ENDMETHOD;

ENDCLASS;
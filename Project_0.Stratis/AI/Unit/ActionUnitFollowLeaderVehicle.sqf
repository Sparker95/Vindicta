#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\Action\Action.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"
#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"

/*
Should be used for a vehicle driver that must follow the lead vehicle in a convoy.
Author: Sparker 13.02.2019
*/

#define pr private

// How much time it's allowed to stand at one place without being considered 'stuck'
#define TIMER_STUCK_TRESHOLD 50

CLASS("ActionUnitFollowLeaderVehicle", "ActionUnit")
	
	VARIABLE("dist"); // Distance to leader's vehicle
	VARIABLE("stuckTimer");
	VARIABLE("time");
	VARIABLE("triedRoads"); // Array with road pieces unit tried to achieve when it got stuck
	
	// ------------ N E W ------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]] ];
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];
		
		pr _hO = GETV(_thisObject, "hO");
		
		// Get distance between the vehicle of this unit and the lead vehicle
		pr _dist = (vehicle _hO) distance (vehicle leader group _hO);
		T_SETV("dist", _dist);
		T_SETV("stuckTimer", 0);
		T_SETV("time", time);
		T_SETV("triedRoads", []);
		
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
			
			OOP_INFO_1("Probably stuck: %1", _timer);
			
			if (_timer > TIMER_STUCK_TRESHOLD) then {
				OOP_INFO_0("Is totally stuck now!");
				
				// Try to doMove to some of the nearest roads
				pr _triedRoads = T_GETV("triedRoads");
				pr _nr = (_ho nearRoads 200) select {! (_x in _triedRoads)};
				if (count _nr > 0) then {
					// Sort roads by distance
					_nr = (_nr apply {[_x, _x distance2D _hO]});
					_nr sort true; // Ascending
					
					// do move to the nearest road piece we didn't visit yet
					pr _road = (_nr select 0) select 0;
					_hO doMove (getpos _road);
					_triedRoads pushBack _road;
					T_SETV("stuckTimer", 0);
				};
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
	} ENDMETHOD; 

ENDCLASS;
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\Action\Action.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"
#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"
#include "common.hpp"

/*
Unit pursues, then searches target. Target is then either let go or arrested, which completes the action.

States of FSM: 
0: Pursuit of target
1: Captor caught up with target, cue search or arrest
2: Action failed
3: Action completed

Action FAILS if target escapes or goes overt, or if unit pursuing is in danger.
Action COMPLETES if target is caught and either searched or arrested.

Author: Jeroen Notenbomer, Marvis
*/

#define pr private

CLASS("ActionUnitArrest", "Action")
	
	VARIABLE("target");
	VARIABLE("objectHandle");
	VARIABLE("startTime");
	VARIABLE("stateMachine");
	VARIABLE("spawnHandle");
	VARIABLE("stateChanged");

	// ------------ N E W ------------
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_target", objNull, [objNull]] ];

		OOP_INFO_0("ActionUnitArrest: Action new method called.");
		OOP_INFO_1("ActionUnitArrest: Target: %1", _target);

		T_SETV("target", _target);
		pr _a = GETV(_AI, "agent"); // cache the object handle
		pr _captor = CALLM(_a, "getObjectHandle", []);
		T_SETV("objectHandle", _captor);		
		T_SETV("spawnHandle", scriptNull);
		T_SETV("stateChanged", false);

		T_SETV("stateMachine", 0);

	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_to", "", [""]]];	

		OOP_INFO_0("ActionUnitArrest: Activated.");	
		
		pr _captor = T_GETV("objectHandle");		
		_captor lockWP false;
		_captor setSpeedMode "NORMAL";

		// time pursuit starts
		T_SETV("startTime", time);

		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);

		// Return ACTIVE state
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];

		OOP_INFO_0("ActionUnitArrest: Processing.");
		OOP_INFO_1("ActionUnitArrest: StateMachine: %1", T_GETV("stateMachine"));
		
		CALLM(_thisObject, "activateIfInactive", []);
		pr _state = ACTION_STATE_ACTIVE;
	
		pr _startTime = T_GETV("startTime");
		pr _captor = T_GETV("objectHandle");
		pr _target = T_GETV("target");

		switch (T_GETV("stateMachine")) do {

			// stateMachine 0, Pursuit of target
			case 0: {	

				_captor dotarget _target;

				// attach script once at start
				if !(T_GETV("stateChanged")) then {

					T_SETV("stateChanged", true);

					pr _handle = [_target,_captor] spawn {
						params["_target","_captor"];
						waitUntil {
							_pos = (eyeDirection _target vectorMultiply 1.6) vectorAdd getpos _target;
							_captor doMove _pos;
							_captor doWatch _target;
							_pos_arrest = getpos _target;
							sleep 0.5;
							_isMoving = !(_pos_disarm distance getpos _target <0.1);
							_target setVariable ["isMoving", _isMoving];
							
							_return = !_isMoving && {_pos distance getpos _captor < 1.5};
							_return
						};
					};
					T_SETV("spawnHandle", _handle);

				} else {



				};

				// condition for leaving current state
				if (scriptDone GETV(_thisObject, "spawnHandle")) then {
					SETV(_thisObject, "stateChanged", true);
					SETV(_thisObject, "stateMachine", 3);
				};

			}; // stateMachine 0

			// stateMachine 1, Captor caught up with target
			case 1: {
				OOP_INFO_0("ActionUnitArrest: StateMachine: 1");	


			}; // stateMachine 1

			// stateMachine 2, action failed
			case 2: {	
				OOP_INFO_0("ActionUnitArrest: StateMachine: 2, FAILED.");
				_state = ACTION_STATE_FAILED;
			}; // stateMachine 2

			// stateMachine 3, action completed
			case 3: {	
				OOP_INFO_0("ActionUnitArrest: StateMachine: 3, COMPLETED.");
				_state = ACTION_STATE_COMPLETED;
			}; // stateMachine 3
		}; // switch end

		
		// Return the current state
		T_SETV("state", _state);
		_state
	} ENDMETHOD;

	// Handle unit being killed/removed from group during action
	METHOD("handleUnitsRemoved") {
		params [["_thisObject", "", [""]], ["_units", [], [[]]]];

		OOP_INFO_0("ActionUnitArrest: handleUnitsRemoved called, action FAILED.");
		T_SETV("state", ACTION_STATE_FAILED);
		
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];

		OOP_INFO_0("ActionUnitArrest: Terminating.");
		
		terminate T_GETV("spawnHandle");
		
		pr _captor = T_GETV("objectHandle");
		_captor doWatch objNull;
		_captor lookAt objNull;
		_captor lockWP false;
		_captor setSpeedMode "LIMITED";
		
	} ENDMETHOD;
ENDCLASS;
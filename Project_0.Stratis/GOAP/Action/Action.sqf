/*
The atomic goal class.
Based on source from "Programming Game AI by Example" by Mat Buckland: http://www.ai-junkie.com/books/toc_pgaibe.html

Author: Sparker 05.08.2018
*/

#include "..\..\OOP_Light\OOP_Light.h"
#include "Action.hpp"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"

CLASS("Action", "MessageReceiver")

	VARIABLE("entity"); // The entity that owns this goal: unit, group, garrison, etc
	VARIABLE("state"); // Status of this goal
	VARIABLE("msgLoop"); // Message loop of this goal, if this goal needs to receive any messages
	VARIABLE("timer"); // The timer which will be sending messages to this goal so that it calls its process method
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// |                                                                    |
	// | Arguments:                                                         |
	// |  _entity - The entity that owns this goal: unit, group, garrison ..|
	// |  _autonomous - if true, a timer will be created to call the        |
	// |   process method of this goal periodically.                        |
	// |   If false, this goal is assumed to be a subgoal and it will not   |
	// |   call its process method on its own.                              |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_entity", "", [""]] ];
		
		if (isNil "gTimerServiceMain") exitWith { diag_log "[Goal::new] Error: main timer service doesnt't exist!"; };
		if (isNil "gMessageLoopGoal") exitWith { diag_log "[Goal::new] Error: global goal message loop doesn't exist!"; };
		
		SET_VAR(_thisObject, "entity", _entity);
		SET_VAR(_thisObject, "state", ACTION_STATE_INACTIVE); // Default state
		SETV(_thisObject, "msgLoop", gMessageLoopGoal);
		
		SETV(_thisObject, "timer", ""); // No timer for this goal until it has been made autonomous
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		
		// Delete the timer of this goal if it exists
		private _timer = GETV(_thisObject, "timer");
		if (_timer != "") then {
			DELETE(_timer);
		};
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T   M E S S A G E   L O O P                  |
	// |                                                                    |
	// | Must implement this since we inherit from MessageReceiver          |
	// ----------------------------------------------------------------------
	
	METHOD("getMessageLoop") {
		params [ ["_thisObject", "", [""]] ];
		GETV(_thisObject, "msgLoop")
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   S E T   M E S S A G E   L O O P                  |
	// |                                                                    |
	// | Sets the message loop for this goal                                |
	// ----------------------------------------------------------------------
	
	METHOD("setMessageLoop") {
		params [["_thisObject", "", [""]], ["_msgLoop", "", [""]] ];
		SETV(_thisObject, "msgLoop", _msgLoop);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   S E T   A U T O N O M O U S                      |
	// |                                                                    |
	// |  Sets the goal to autonomous mode                                  |
	// |  Autonomous goals have a timer which generate a message to call    |
	// | the goal's process method                                          |
	// ----------------------------------------------------------------------
	
	METHOD("setAutonomous") {
		params [["_thisObject", "", [""]], ["_timerPeriod", 1, [1]] ];
		private _msg = MESSAGE_NEW();
		_msg set [MESSAGE_ID_DESTINATION, _thisObject];
		_msg set [MESSAGE_ID_SOURCE, ""];
		_msg set [MESSAGE_ID_DATA, 0];
		_msg set [MESSAGE_ID_TYPE, ACTION_MESSAGE_PROCESS];
		private _args = [_thisObject, _timerPeriod, _msg, gTimerServiceMain]; // message receiver, interval, message, timer service
		private _timer = NEW("Timer", _args);
		SETV(_thisObject, "timer", _timer);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                      H A N D L E   M E S S A G E                   |
	// |                                                                    |
	// | Call this from handleMessage of inherited classes. If it returns   |
	// | true, it means message has been handled.                           |
	// ----------------------------------------------------------------------
	
	METHOD("handleMessage") { //Derived classes must implement this method
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
		private _msgType = _msg select MESSAGE_ID_TYPE;
		private _msgHandled = false;
		
		switch (_msgType) do {
			case MESSAGE_UNIT_DESTROYED: {
				diag_log "[Goal::handleMessage] Info: unit was destroyed";
				SETV(_thisObject, "state", ACTION_STATE_FAILED);
				_msgHandled = true; // message handled
			};
		
			case ACTION_MESSAGE_PROCESS: {
				//diag_log format ["[Goal::handleMessage] Info: Calling process method...", _msg];
				CALLM(_thisObject, "process", []);
				_msgHandled = true; // message handled
			};
		
			case ACTION_MESSAGE_DELETE: {
				CALLM(_thisObject, "terminate", []);
				DELETE(_thisObject);
				_msgHandled = true; // message handled
			};
		};
		
		_msgHandled
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                 A C T I V A T E   I F   I N A C T I V E            |
	// ----------------------------------------------------------------------

	METHOD("activateIfInactive") {
		params [["_thisObject", "", [""]]];
		private _state = GETV(_thisObject, "state");
		if (_state == ACTION_STATE_INACTIVE) then {
			_state = CALLM(_thisObject, "activate", []);
		};
		_state
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                 R E A C T I V A T E   I F   F A I L E D            |
	// ----------------------------------------------------------------------
	
	METHOD("reactivateIfFailed") {
		params [["_thisObject", "", [""]]];
		private _state = GETV(_thisObject, "state");
		if (_state == ACTION_STATE_FAILED) then {
			CALLM(_thisObject, "activate", []);
		};
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                      V I R T U A L   M E T H O D S                 |
	// ----------------------------------------------------------------------
	
	// logic to run when the goal is activated
	/* virtual */ METHOD("activate") {} ENDMETHOD;
	
	// logic to run each update-step
	/* virtual */ METHOD("process") {} ENDMETHOD;
	
	// logic to run when the goal is satisfied
	/* virtual */ METHOD("terminate") {} ENDMETHOD; 
	
	// a Goal is atomic and cannot aggregate subgoals yet we must implement
	// this method to provide the uniform interface required for the goal
	// hierarchy.
	/* virtual */ METHOD("addSubgoal") { diag_log "[Goal::addSubgoal] Error: can't add a subgoal to an atomic goal!"; } ENDMETHOD;
	
	// Returns the list of subgoals (for debug purposes)
	/* virtual */ METHOD("getSubgoals") { [] } ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                         S T A T E   C H E C K S                    |
	// |                                                                    |
	// | Methods for checking the state of the goal                         |
	// ----------------------------------------------------------------------
	
	METHOD("isCompleted") {
		params [ ["_thisObject", "", [""]] ];
		private _state = GETV(_thisObject, "state"); _state == ACTION_STATE_COMPLETED
	} ENDMETHOD;
	
	METHOD("isActive") {
		params [["_thisObject", "", [""]]];
		(GETV(_thisObject, "state")) == ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	METHOD("isInactive") {
		params [["_thisObject", "", [""]]];
		(GETV(_thisObject, "state")) == ACTION_STATE_INACTIVE
	} ENDMETHOD;
	
	METHOD("isFailed") {
		params [["_thisObject", "", [""]]];
		(GETV(_thisObject, "state")) == ACTION_STATE_COMPLETED
	} ENDMETHOD;
ENDCLASS;
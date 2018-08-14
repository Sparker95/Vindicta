/*
An atomic goal for a unit to sit on a bench for some duration of time.
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Goal\Goal.hpp"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"

CLASS("GoalUnitDoSitOnBench", "Goal")

	VARIABLE("bench");
	VARIABLE("pointID");
	VARIABLE("sitDuration");
	VARIABLE("timeCompleted"); // The time when this goal will be completed
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_entity", "", [""]], ["_bench", "", [""]], ["_sitDuration", 0, [0]], ["_pointID", 0, [0]]];
		SETV(_thisObject, "bench", _bench);
		SETV(_thisObject, "pointID", _pointID);
		SETV(_thisObject, "sitDuration", _sitDuration);
		SETV(_thisObject, "timeCompleted", (time + _sitDuration));
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                        A C T I V A T E                             |
	// ----------------------------------------------------------------------

	METHOD("activate") {
		params [["_thisObject", "", [""]]];
		
		// Get variables
		private _entity = GETV(_thisObject, "entity");
		private _bench = GETV(_thisObject, "bench");
		private _pointID = GETV(_thisObject, "pointID");
		
		// Is the desired point still free?
		if (CALLM(_bench, "isPointFree", [_pointID])) then {
			private _sitDuration = GETV(_thisObject, "sitDuration");
			SETV(_thisObject, "timeCompleted", (time + _sitDuration)); // Set how long we need to sit here
			private _args = [_bench, _pointID];
			private _sitSuccessfull = CALLM(_entity, "doSitOnBench", _args);
			if (_sitSuccessfull) then {
				// Set the time variable
				private _sitDuration = GETV(_thisObject, "sitDuration");
				SETV(_thisObject, "timeCompleted", (time + _sitDuration));
			
				SETV(_thisObject, "state", GOAL_STATE_ACTIVE);
				GOAL_STATE_ACTIVE
			} else {
				SETV(_thisObject, "state", GOAL_STATE_FAILED);
				GOAL_STATE_FAILED
			};
		} else {
			// Someone has occupied the desired sit point!
			SETV(_thisObject, "state", GOAL_STATE_FAILED);
			GOAL_STATE_FAILED
		};
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                          P R O C E S S                             |
	// ----------------------------------------------------------------------

	METHOD("process") {
		params [["_thisObject", "", [""]]];
		private _state = CALLM(_thisObject, "activateIfInactive", []);		
		
		if (_state != GOAL_STATE_FAILED) then {
			// Check if we have been sitting enough
			private _timeCompleted = GETV(_thisObject, "timeCompleted");
			if (time > _timeCompleted) then {
				SETV(_thisObject, "state", GOAL_STATE_COMPLETED);
				_state = GOAL_STATE_COMPLETED;
			} else {
				SETV(_thisObject, "state", GOAL_STATE_ACTIVE);
				_state = GOAL_STATE_ACTIVE;
			};
		};
		
		_state
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                        T E R M I N A T E                           |
	// ----------------------------------------------------------------------

	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		private _state = GETV(_thisObject, "state");
		if (_state == GOAL_STATE_ACTIVE || _state == GOAL_STATE_COMPLETED) then {
			// Get back on your feet!
			private _entity = GETV(_thisObject, "entity");
			CALLM(_entity, "doGetUpFromBench", []);
			
			// Notify the bench that this seat is now free
			private _bench = GETV(_thisObject, "bench");
			private _pointID = GETV(_thisObject, "pointID");
			CALLM(_bench, "pointIsFree", [_pointID]);
		};
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                      H A N D L E   M E S S A G E                   |
	// |                                                                    |
	// | This goal accepts only GOAL_MESSAGE_ANIMATION_INTERRUPTED message and base class messages
	// ----------------------------------------------------------------------
	METHOD("handleMessage") { //Derived classes must implement this method
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
		private _msgType = _msg select MESSAGE_ID_TYPE;
		
		private _msgHandled = false;
		if (_msgType == GOAL_MESSAGE_ANIMATION_INTERRUPTED) then {
			diag_log "------------- Animation was interrupted!";
			// The animation was interrupted, so we must set this goal to failed state
			SETV(_thisObject, "state", GOAL_STATE_FAILED);
			_msgHandled = true // message has been handled
		} else {
			// Pass message to handleMessage of the base class
			_msgHandled = CALL_CLASS_METHOD("Goal", "handleMessage", [_msg]);
		};
		_msgHandled
	} ENDMETHOD;

ENDCLASS;
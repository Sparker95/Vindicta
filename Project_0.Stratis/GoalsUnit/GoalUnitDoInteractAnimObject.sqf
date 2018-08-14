/*
An atomic goal for a unit to interact with an animObject for some duration of time.
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Goal\Goal.hpp"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"

CLASS("GoalUnitDoInteractAnimObject", "Goal")

	VARIABLE("animObject");
	VARIABLE("pointID");
	VARIABLE("animDuration");
	VARIABLE("animationOut");
	VARIABLE("timeCompleted"); // The time when this goal will be completed
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_entity", "", [""]], ["_animObject", "", [""]], ["_animDuration", 0, [0]], ["_pointID", 0, [0]]];
		SETV(_thisObject, "animObject", _animObject);
		SETV(_thisObject, "pointID", _pointID);
		SETV(_thisObject, "animDuration", _animDuration);
		SETV(_thisObject, "animationOut", ""); // Actual value will be retrieved on goal activation
		SETV(_thisObject, "timeCompleted", (time + _animDuration));
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
		private _animObject = GETV(_thisObject, "animObject");
		private _pointID = GETV(_thisObject, "pointID");
		
		// Is the desired point still free?
		private _args = [_animObject, _pointID];
		private _pointData = CALLM(_animObject, "getPointData", _args); // pointData: ["_posOffset", "_dir", "_animation", "_animationOut"]
		if ( count _pointData > 0 ) then {
			// Parse point data
			_pointData params ["_posOffset", "_dir", "_animation", "_animationOut"];
			private _objectHandle = CALLM(_animObject, "getObject", []);
			// Convert model to world
			_dir = _dir + (direction _objectHandle);
			private _pos = _objectHandle modelToWorld _posOffset;
			SETV(_thisObject, "animationOut", _animationOut); // Store the animation out in case we need to terminate this goal
			// Play the actual animation
			private _args = [_pos, _dir, _animation, _animationOut];
			private _animSuccessfull = CALLM(_entity, "doInteractAnimObject", _args);
			if (_animSuccessfull) then {
				// Set the time variable to terminate this goal when the time is out
				private _animDuration = GETV(_thisObject, "animDuration");
				SETV(_thisObject, "timeCompleted", (time + _animDuration));
				SETV(_thisObject, "state", GOAL_STATE_ACTIVE);
				GOAL_STATE_ACTIVE
			} else {
				SETV(_thisObject, "state", GOAL_STATE_FAILED);
				GOAL_STATE_FAILED
			};
		} else {
			// Someone has occupied the desired point!
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
			// Check if we have been playing the animation for enough time
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
			private _animationOut = GETV(_thisObject, "animationOut");
			// Get back on your feet!
			private _entity = GETV(_thisObject, "entity");
			private _args = [_animationOut, 0, 2];
			CALLM(_entity, "doStopInteractAnimObject", _args);
			
			// Notify the animObject that this seat is now free
			private _animObject = GETV(_thisObject, "animObject");
			private _pointID = GETV(_thisObject, "pointID");
			CALLM(_animObject, "pointIsFree", [_pointID]);
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
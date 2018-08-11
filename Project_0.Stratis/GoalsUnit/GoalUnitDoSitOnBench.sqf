/*
An atomic goal for a unit to sit on a bench for some duration of time.
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Goal\Goal.hpp"

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
			} else {
				SETV(_thisObject, "state", GOAL_STATE_FAILED);
			};
		} else {
			// Someone has occupied the desired sit point!
			SETV(_thisObject, "state", GOAL_STATE_FAILED);
		};
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                          P R O C E S S                             |
	// ----------------------------------------------------------------------

	METHOD("process") {
		params [["_thisObject", "", [""]]];
		CALLM(_thisObject, "activateIfInactive", []);		
		
		// Check if we have been sitting enough
		private _timeCompleted = GETV(_thisObject, "timeCompleted");
		if (time > _timeCompleted) then {
			SETV(_thisObject, "state", GOAL_STATE_COMPLETED);
			GOAL_STATE_COMPLETED
		} else {
			GOAL_STATE_FAILED
		};
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
			// Move forward a little
			private _unitObject = CALLM(_entity, "getObjectHandle", []);
			private _posMoveTo = _unitObject getPos [2.5, direction _unitObject];
			CALLM(_entity, "doMoveInf", [_posMoveTo]);
		};
	} ENDMETHOD;

ENDCLASS;
/*
A goal for an infantry unit to move to some place.
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Goal\Goal.hpp"

CLASS("GoalUnitMoveInf", "Goal")

	VARIABLE("destPos");
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_entity", "", [""]], ["_destPos", [], [[]]]];
		SETV(_thisObject, "destPos", _destPos);
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
		private _entity = GETV(_thisObject, "entity");
		private _destPos = GETV(_thisObject, "destPos");
		CALLM(_entity, "doMoveInf", [_destPos]);
		SETV(_thisObject, "state", GOAL_STATE_ACTIVE);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                          P R O C E S S                             |
	// ----------------------------------------------------------------------

	METHOD("process") {			
		params [["_thisObject", "", [""]]];
		CALLM(_thisObject, "activateIfInactive", []);		
		
		// Check if we have stuck
		
		// Check if we have arrived
		private _entity = GETV(_thisObject, "entity");
		private _destPos = GETV(_thisObject, "destPos");
		private _distance = CALLM(_entity, "distance", [_destPos]);
		if (_distance < 2.2) then { // Are we there yet???
			// We have arrived!
			SETV(_thisObject, "state", GOAL_STATE_COMPLETED);
			//CALLM(_thisObject, "terminate", []);
			
			GOAL_STATE_COMPLETED // return
		} else {
			GOAL_STATE_ACTIVE
		};
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                        T E R M I N A T E                           |
	// ----------------------------------------------------------------------

	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		if (CALLM(_thisObject, "isActive", [])) then {
			private _entity = GETV(_thisObject, "entity");
			CALLM(_entity, "doStopInf");
		};
	} ENDMETHOD;

ENDCLASS;
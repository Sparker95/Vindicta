#include "common.hpp"

/*
Garrison moves on available vehicles
*/

#define pr private

#define THIS_ACTION_NAME "ActionGarrisonMoveMountedCargo"

CLASS(THIS_ACTION_NAME, "Action")

	VARIABLE("AI");
	
	// ------------ N E W ------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]] ];
		SETV(_thisObject, "AI", _a);
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];		
		
		// Set state
		SETV(_thisObject, "state", ACTION_STATE_ACTIVE);
		
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		CALLM0(_thisObject, "activateIfInactive");
		
		// Return the current state
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
	} ENDMETHOD;
	
	// Calculates cost of this action
	/*
	STATIC_METHOD("getCost") {
		//params [ ["_thisClass", "", [""]], ["_AI", "", [""]], ["_wsStart", [], [[]]], ["_wsEnd", [], [[]]]];
		
		// Return cost
		2
	} ENDMETHOD;
	*/

ENDCLASS;
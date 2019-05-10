#include "common.hpp"

/*
Template of an Action class
*/

#define pr private

CLASS("ActionGarrisonLoadCargo", "Action")

	VARIABLE("AI");
	
	// ------------ N E W ------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]] ];
		SETV(_thisObject, "AI", _AI);
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
	
	// Returns preconditions of this action depending on parameters
	// By default it tries to apply parameters to preconditions, if preconditions reference any parameters
	// !!! If an action must provide preconditions which can't be copied from goal parameters, it must re-implement this method
	STATIC_METHOD("getPreconditions") {
		params [ ["_thisClass", "", [""]], ["_goalParameters", [], [[]]], ["_actionParameters", [], [[]]]];
		
		pr _wsPre = +(GET_STATIC_VAR(_thisClass, "preconditions"));
		[_wsPre, WSP_GAR_VEHICLES_POSITION, getPos player] call ws_setPropertyValue;
		
		_wsPre		
	} ENDMETHOD;
	
ENDCLASS;
#include "common.hpp"

/*
Class: ActionGroup.ActionGroupVehicleClearArea
...
*/

#define pr private


CLASS("ActionGroupVehicleClearArea", "ActionGroup")
	
	VARIABLE("pos");
	VARIABLE("radius");
	
	// ------------ N E W ------------
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];

		pr _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		pr _radius = CALLSM2("Action", "getParameterValue", _parameters, TAG_RADIUS);
		T_SETV("pos", _pos);
		T_SETV("radius", _radius);

	} ENDMETHOD;

	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_to", "", [""]]];		
		
		pr _pos = T_GETV("pos");
		pr _radius = T_GETV("radius");		
		
		// Return ACTIVE state
		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		CALLM(_thisObject, "activateIfInactive", []);
		
		// This action is terminal because it's never over right now
		
		// Return the current state
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
	} ENDMETHOD;

ENDCLASS;
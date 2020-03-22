#include "common.hpp"

/*
Class: ActionGroup.ActionGroupVehicleClearArea
...

I think it's not used any more????
*/

#define pr private


CLASS("ActionGroupVehicleClearArea", "ActionGroup")
	
	VARIABLE("pos");
	VARIABLE("radius");
	
	// ------------ N E W ------------
	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		pr _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		T_SETV("pos", _pos);
		pr _radius = CALLSM2("Action", "getParameterValue", _parameters, TAG_CLEAR_RADIUS);
		T_SETV("radius", _radius);

	} ENDMETHOD;

	// logic to run when the goal is activated
	METHOD("activate") {
		params [P_THISOBJECT];		
		
		pr _pos = T_GETV("pos");
		pr _radius = T_GETV("radius");		
		
		// Return ACTIVE state
		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [P_THISOBJECT];
		
		T_CALLM0("failIfEmpty");
		T_CALLM0("activateIfInactive");

		// This action is terminal because it's never over right now

		// Return the current state
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [P_THISOBJECT];
		
	} ENDMETHOD;

ENDCLASS;
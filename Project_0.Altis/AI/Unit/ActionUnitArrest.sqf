#include "common.hpp"

/*
Action to arrest/restrain player made suspicious by their undercoverMonitor
Author: Marvis 09.05.2019
*/

#define pr private

CLASS("ActionUnitArrest", "ActionUnit")
	
	// ------------ N E W ------------
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];

		OOP_INFO_0("ActionUnitArrest: Activated.");

		// Handle AI just spawned state
		pr _AI = T_GETV("AI");
		if (GETV(_AI, "new")) then {
			SETV(_AI, "new", false);
		};
		
		T_SETV("state", ACTION_STATE_ACTIVE);
		
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];

		OOP_INFO_0("ActionUnitArrest: Process.");
		
		pr _state = CALLM0(_thisObject, "activateIfInactive");

		T_SETV("state", _state);
		_state
	} ENDMETHOD;
	
	// logic to run when the goal is about to be terminated

	METHOD("terminate") {
		params [["_thisObject", "", [""]]];

		OOP_INFO_0("ActionUnitArrest: Terminated.");	
		
	} ENDMETHOD; 

ENDCLASS;
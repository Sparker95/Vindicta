#include "common.hpp"

/*
Class: ActionUnit.ActionUnitSurrender
*/

CLASS("ActionUnitSurrender", "ActionUnit")
		
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];

		private _hO = T_GETV("hO");
		_hO spawn{
			sleep random 6;
			_this call misc_fnc_actionDropAllWeaponsAndSurrender
		};

		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);

		// Return ACTIVE state
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		CALLM(_thisObject, "activateIfInactive", []);
		
		ACTION_STATE_COMPLETED
	} ENDMETHOD;
	
ENDCLASS;

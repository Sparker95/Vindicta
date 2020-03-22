#include "common.hpp"

/*
Merges or splits vehicle group(s)
We need to merge vehicle groups into one group for convoy.
This action also moves ungrouped vehicles into the common vehicle group.

Parameters:
_merge - true to merge, false to split
*/

#define pr private

CLASS("ActionGarrisonMergeVehicleGroups", "ActionGarrison")

	VARIABLE("merge");

	// ------------ N E W ------------

	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
		pr _merge = CALLSM2("Action", "getParameterValue", _parameters, TAG_MERGE);
		T_SETV("merge", _merge);
	} ENDMETHOD;

	// logic to run when the goal is activated
	METHOD("activate") {
		params [P_THISOBJECT];

		pr _gar = T_GETV("gar");
		pr _merge = T_GETV("merge");
		if(_merge) then {
			CALLM0(_gar, "mergeVehicleGroups");
		} else {
			CALLM0(_gar, "splitVehicleGroups");
		};

		// Set world state
		// Let's not set it, we need to see if bots work well since now
		/*
		pr _AI = T_GETV("AI");
		pr _ws = GETV(_AI, "worldState");
		[_ws, WSP_GAR_VEHICLE_GROUPS_MERGED, _merge] call ws_setPropertyValue;
		*/

		// Set state
		T_SETV("state", ACTION_STATE_COMPLETED);

		// We are done here
		ACTION_STATE_COMPLETED

	} ENDMETHOD;

	// logic to run each update-step
	METHOD("process") {
		params [P_THISOBJECT];

		pr _state = CALLM0(_thisObject, "activateIfInactive");

		// Return the current state
		_state
	} ENDMETHOD;

	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [P_THISOBJECT];
	} ENDMETHOD;

ENDCLASS;
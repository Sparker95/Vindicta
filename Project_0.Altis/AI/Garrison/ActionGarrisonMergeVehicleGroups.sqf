#include "common.hpp"

/*
Merges or splits vehicle group(s)
We need to merge vehicle groups into one group for convoy.
This action also moves ungrouped vehicles into the common vehicle group.

Parameters:
_merge - true to merge, false to split
*/

#define pr private

#define THIS_ACTION_NAME "ActionGarrisonMergeVehicleGroups"

CLASS(THIS_ACTION_NAME, "ActionGarrison")
	
	VARIABLE("merge");
	
	// ------------ N E W ------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];
		
		pr _merge = CALLSM2("Action", "getParameterValue", _parameters, TAG_MERGE);
		T_SETV("merge", _merge);
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];		
		
		pr _gar = T_GETV("gar");
		pr _merge = T_GETV("merge");
		CALLM1(_gar, "mergeVehicleGroups", _merge);
		
		// Set world state
		pr _AI = T_GETV("AI");
		pr _ws = GETV(_AI, "worldState");
		[_ws, WSP_GAR_VEHICLE_GROUPS_MERGED, _merge] call ws_setPropertyValue;

		// Set state
		SETV(_thisObject, "state", ACTION_STATE_COMPLETED);
		
		// We are done here
		ACTION_STATE_COMPLETED
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		pr _state = CALLM0(_thisObject, "activateIfInactive");
		
		// Return the current state
		_state
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
	} ENDMETHOD;

ENDCLASS;
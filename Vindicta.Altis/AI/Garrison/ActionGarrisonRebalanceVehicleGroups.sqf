#include "common.hpp"

/*
This action tries to find drivers and turret operators for vehicles in all vehicle groups
*/

#define pr private

CLASS("ActionGarrisonRebalanceVehicleGroups", "ActionGarrison")

	// ------------ N E W ------------
	
	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [P_THISOBJECT];

		OOP_INFO_0("ACTIVATE");

		pr _gar = T_GETV("gar");

		CALLM0(_gar, "rebalanceGroups");

		pr _AI = T_GETV("AI");
		// Call the health sensor again so that it can update the world state properties
		CALLM0(GETV(_AI, "sensorState"), "update");

		pr _ws = GETV(_AI, "worldState");

		pr _state = if ([_ws, WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_DRIVERS, true] call ws_propertyExistsAndEquals) then {
			ACTION_STATE_COMPLETED
		} else {
			ACTION_STATE_FAILED
		};

		// Set state
		T_SETV("state", _state);
		
		// Return ACTIVE state
		_state
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [P_THISOBJECT];
		
		pr _state = CALLM0(_thisObject, "activateIfInactive");
		
		// Return the current state
		T_SETV("state", _state);
		_state
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [P_THISOBJECT];
		
	} ENDMETHOD;

ENDCLASS;
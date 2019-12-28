#include "common.hpp"

/*
Author: Sparker 26.11.2018
*/

#define pr private

#define RETURN 

#ifndef RELEASE_BUILD
//#define DEBUG_ACTION_UNIT_DISMOUNT_CURRENT_VEHICLE
#endif

CLASS("ActionUnitDismountCurrentVehicle", "ActionUnit")

	// ------------ N E W ------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]] ];

	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];
		
		#ifdef DEBUG_ACTION_UNIT_DISMOUNT_CURRENT_VEHICLE
		OOP_INFO_0("ACTIVATE");
		#endif

		// Handle AI just spawned state
		pr _AI = T_GETV("AI");
		if (GETV(_AI, "new")) then {
			SETV(_AI, "new", false);
		};
		
		pr _hO = GETV(_thisObject, "hO");
		/*
		if (vehicle _hO isEqualTo _hO) then {
			// We are done here
			// Good job
			// Outstanding
			
			#ifdef DEBUG_ACTION_UNIT_DISMOUNT_CURRENT_VEHICLE
			OOP_INFO_0("Completed at activation");
			#endif
			
			SETV(_thisObject, "state", ACTION_STATE_COMPLETED);
			RETURN ACTION_STATE_COMPLETED;
		} else {
		*/
			// Unassign from vehicle
			
			pr _AI = GETV(_thisObject, "AI");
			
			#ifdef DEBUG_ACTION_UNIT_DISMOUNT_CURRENT_VEHICLE
			OOP_INFO_1("Unassigning %1 from vehicle", _AI);
			#endif
			
			CALLM0(_AI, "unassignVehicle");
		
			// Set state
			SETV(_thisObject, "state", ACTION_STATE_ACTIVE);
			// Return ACTIVE state
			RETURN ACTION_STATE_ACTIVE;
		//};		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		#ifdef DEBUG_ACTION_UNIT_DISMOUNT_CURRENT_VEHICLE
		OOP_INFO_0("PROCESS");
		#endif
		
		pr _state = CALLM0(_thisObject, "activateIfInactive");
		
		if (_state == ACTION_STATE_ACTIVE) then {
			pr _hO = GETV(_thisObject, "hO");
			// Did we dismount already?
			if ((vehicle _hO) isEqualTo _hO) then {
			
				#ifdef DEBUG_ACTION_UNIT_DISMOUNT_CURRENT_VEHICLE
				OOP_INFO_0("Unit has dismounted");
				#endif
			
				// If yes, the action is complete
				SETV(_thisObject, "state", ACTION_STATE_COMPLETED);
				
				// Return
				RETURN ACTION_STATE_COMPLETED;
			} else {
			
				#ifdef DEBUG_ACTION_UNIT_DISMOUNT_CURRENT_VEHICLE
				OOP_INFO_0("Unit has not dismounted");
				#endif
			
				// If not, order to dismount
				pr _AI = T_GETV("AI");
				CALLM0(_AI, "unassignVehicle");
				
				// Return
				RETURN ACTION_STATE_ACTIVE;
			};
		} else {
			RETURN _state;
		};
	} ENDMETHOD;
	
	// logic to run when the goal is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
	} ENDMETHOD; 

ENDCLASS;


/*
Code for testing this action quickly.
Will make the unit sitting inside cursorObject dismount.

// GetOut
_unit = (crew cursorObject) select 0;
_parameters = [];

newAction = [_unit, "ActionUnitDismountCurrentVehicle", _parameters, 1] call AI_misc_fnc_forceUnitAction;
*/
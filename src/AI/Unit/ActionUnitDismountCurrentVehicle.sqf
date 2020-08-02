#include "common.hpp"

/*
Author: Sparker 26.11.2018
*/

#define pr private

#define RETURN 

#ifndef RELEASE_BUILD
//#define DEBUG_ACTION_UNIT_DISMOUNT_CURRENT_VEHICLE
#endif

#define OOP_CLASS_NAME ActionUnitDismountCurrentVehicle
CLASS("ActionUnitDismountCurrentVehicle", "ActionUnit")

	// ------------ N E W ------------
	
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI") ];

	ENDMETHOD;
	
	// logic to run when the goal is activated
	protected override METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];
		
		#ifdef DEBUG_ACTION_UNIT_DISMOUNT_CURRENT_VEHICLE
		OOP_INFO_0("ACTIVATE");
		#endif

		// Handle AI just spawned state
		/*
		if (vehicle _hO isEqualTo _hO) then {
			// We are done here
			// Good job
			// Outstanding
			
			#ifdef DEBUG_ACTION_UNIT_DISMOUNT_CURRENT_VEHICLE
			OOP_INFO_0("Completed at activation");
			#endif
			
			T_SETV("state", ACTION_STATE_COMPLETED);
			RETURN ACTION_STATE_COMPLETED;
		} else {
		*/
		// Unassign from vehicle
		
		pr _AI = T_GETV("AI");
		
		#ifdef DEBUG_ACTION_UNIT_DISMOUNT_CURRENT_VEHICLE
		OOP_INFO_1("Unassigning %1 from vehicle", _AI);
		#endif
		
		CALLM0(_AI, "unassignVehicle");

		pr _state = if(_instant) then {
			moveOut T_GETV("hO");
			ACTION_STATE_COMPLETED
		} else {
			ACTION_STATE_ACTIVE
		};

		T_SETV("state", _state);
		_state;
	ENDMETHOD;
	
	// logic to run each update-step
	public override METHOD(process)
		params [P_THISOBJECT];
		
		#ifdef DEBUG_ACTION_UNIT_DISMOUNT_CURRENT_VEHICLE
		OOP_INFO_0("PROCESS");
		#endif
		
		pr _state = T_CALLM0("activateIfInactive");
		
		if (_state == ACTION_STATE_ACTIVE) then {
			pr _hO = T_GETV("hO");
			// Did we dismount already?
			if ((vehicle _hO) isEqualTo _hO) then {
			
				#ifdef DEBUG_ACTION_UNIT_DISMOUNT_CURRENT_VEHICLE
				OOP_INFO_0("Unit has dismounted");
				#endif
			
				// If yes, the action is complete
				T_SETV("state", ACTION_STATE_COMPLETED);
				
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
	ENDMETHOD;
	
	// logic to run when the goal is satisfied
	public override METHOD(terminate)
		params [P_THISOBJECT];
	ENDMETHOD;

ENDCLASS;


/*
Code for testing this action quickly.
Will make the unit sitting inside cursorObject dismount.

// GetOut
_unit = (crew cursorObject) select 0;
_parameters = [];

newAction = [_unit, "ActionUnitDismountCurrentVehicle", _parameters, 1] call AI_misc_fnc_forceUnitAction;
*/
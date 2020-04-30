#include "common.hpp"

/*
Class: ActionGroup.ActionGroupUnflipVehicles
Flipped vehicles get magically unflipped
*/

#define pr private

#define OOP_CLASS_NAME ActionGroupUnflipVehicles
CLASS("ActionGroupUnflipVehicles", "ActionGroup")

	// logic to run when the goal is activated
	METHOD(activate)
		params [P_THISOBJECT];
		
		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");
		
		// Get flipped vehicles
		pr _vehicleUnits = CALLM0(_group, "getUnits") select {CALLM0(_x, "isVehicle")};
		{
			pr _vehAI = CALLM0(_x, "getAI");
			CALLM4(_vehAI, "addExternalGoal", "GoalUnitVehicleUnflip", 0, [], _AI);
		} forEach _vehicleUnits;
		
		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);
		
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	ENDMETHOD;
	
	// logic to run each update-step
	METHOD(process)
		params [P_THISOBJECT];
		
		T_CALLM0("failIfEmpty");
		
		pr _state = T_CALLM0("activateIfInactive");
		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");
		
		if (_state == ACTION_STATE_ACTIVE) then {
			pr _vehicleUnits = CALLM0(_group, "getUnits") select {CALLM0(_x, "isVehicle")};
			//pr _vehicleAIs = _vehicleUnits apply {CALLM0(_x, "getAI")};
			
			// Action is over when all vehicles are done with their actions
			if (CALLSM3("AI_GOAP", "allAgentsCompletedExternalGoal", _vehicleUnits, "GoalUnitVehicleUnflip", _AI)) then {
				// Force update of flipping sensors
				private _AI = T_GETV("AI");
				pr _h = GETV(_AI, "sensorHealth");
				CALLM0(_h, "update");
				
				_state = ACTION_STATE_COMPLETED;
			};
		};
		
		// Return the current state
		_state
	ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD(terminate)
		params [P_THISOBJECT];
		
		// Delete assigned goals
		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");
		
		pr _vehicleUnits = CALLM0(_group, "getUnits") select {CALLM0(_x, "isVehicle")};
		pr _vehicleAIs = _vehicleUnits apply {CALLM0(_x, "getAI")};
		
		{
			CALLM2(_x, "deleteExternalGoal", "GoalUnitVehicleUnflip", _AI);
		} forEach _vehicleAIs;
		
	ENDMETHOD;

ENDCLASS;
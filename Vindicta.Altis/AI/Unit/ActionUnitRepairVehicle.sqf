#include "common.hpp"

/*
Class: ActionUnit.ActionUnitRepairVehicle
Makes a unit play the repair animation and repair a target vehicle. Doesn't make the unit move anywhere.

Parameters: "vehicle" - <Unit> object
*/

#define pr private

#define OOP_CLASS_NAME ActionUnitRepairVehicle
CLASS("ActionUnitRepairVehicle", "ActionUnit")
	
	VARIABLE("veh");
	VARIABLE("timeActivated");
	
	// ------------ N E W ------------
	
	
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
		pr _veh = CALLSM2("Action", "getParameterValue", _parameters, "vehicle");
		T_SETV("veh", _veh);
	ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD(activate)
		params [P_THISOBJECT];
		
		pr _hO = T_GETV("hO");
		pr _veh = T_GETV("veh");
		pr _hVeh = CALLM0(_veh, "getObjectHandle");
		
		_hO action ["repairVehicle", _hVeh];
		
		T_SETV("timeActivated", GAME_TIME);
		
		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);
		
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
	ENDMETHOD;
	
	// logic to run each update-step
	METHOD(process)
		params [P_THISOBJECT];
		
		pr _state = T_CALLM0("activateIfInactive");
		
		if (_state == ACTION_STATE_ACTIVE) then {
			// Makethe actual repair affects lag behind the animation
			if (GAME_TIME - T_GETV("timeActivated") > 5) then {
				pr _hO = T_GETV("hO");
				pr _veh = T_GETV("veh");
				// Check if the unit is not an actual engineer
				if (!(_hO getUnitTrait "engineer")) then {
					[CALLM0(_veh, "getObjectHandle")] call AI_misc_fnc_repairWithoutEngineer; // Will do partial repairs of vehicle
				};
				_state = ACTION_STATE_COMPLETED;
			};
		};
		
		T_SETV("state", _state);
		_state
	ENDMETHOD;
	
	// logic to run when the action is satisfied
	/*
	METHOD(terminate)
		params [P_THISOBJECT];
	ENDMETHOD;
	*/
	
ENDCLASS;
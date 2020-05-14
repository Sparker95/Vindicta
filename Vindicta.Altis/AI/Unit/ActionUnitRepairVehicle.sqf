#include "common.hpp"

/*
Class: ActionUnit.ActionUnitRepairVehicle
Makes a unit play the repair animation and repair a target vehicle. Doesn't make the unit move anywhere.

Parameters: "vehicle" - <Unit> object
*/

#define pr private

#define OOP_CLASS_NAME ActionUnitRepairVehicle
CLASS("ActionUnitRepairVehicle", "ActionUnit")
	
	VARIABLE("hVeh");
	VARIABLE("timeActivated");
	
	METHOD(getPossibleParameters)
		[
			[ [TAG_TARGET_REPAIR, [objNull] ] ],	// Required parameters
			[ ]	// Optional parameters
		]
	ENDMETHOD;
	
	// ------------ N E W ------------
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
		pr _veh = CALLSM2("Action", "getParameterValue", _parameters, TAG_TARGET_REPAIR);
		T_SETV("hVeh", _veh);
	ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD(activate)
		params [P_THISOBJECT];
		
		pr _hO = T_GETV("hO");
		pr _hVeh = T_GETV("hVeh");
		
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
				pr _hveh = T_GETV("hVeh");
				// Check if the unit is not an actual engineer
				// Doesn't matter much actually
				// Sometimes engineers can be without toolkit and thus unable to repair vehicle in arma-native way
				//if (!(_hO getUnitTrait "engineer")) then {
					[_hVeh] call AI_misc_fnc_repairWithoutEngineer; // Will do partial repairs of vehicle
				//};
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
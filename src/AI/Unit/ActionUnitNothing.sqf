#include "common.hpp"

/*
A dummy unit action which just resets the "spawned" state of AI object.
Author: Sparker 13.02.2019
*/

#define pr private

#define OOP_CLASS_NAME ActionUnitNothing
CLASS("ActionUnitNothing", "ActionUnit")
	
	// ------------ N E W ------------
	
	// logic to run when the goal is activated
	protected override METHOD(activate)
		params [P_THISOBJECT];
		
		// Handle AI just spawned state
		T_SETV("state", ACTION_STATE_COMPLETED);
		ACTION_STATE_COMPLETED
	ENDMETHOD;
	
	// logic to run each update-step
	public override METHOD(process)
		params [P_THISOBJECT];
		
		pr _state = T_CALLM0("activateIfInactive");

		T_SETV("state", _state);
		_state
	ENDMETHOD;
	
	// logic to run when the goal is about to be terminated
	/*
	public override METHOD(terminate)
		params [P_THISOBJECT];
		
	ENDMETHOD;
	*/

ENDCLASS;
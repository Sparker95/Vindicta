#include "common.hpp"

/*
Class: ActionUnit.ActionUnitInfantryLeaveFormation
Makes unit not follow his leader any more
*/

#define pr private

#define OOP_CLASS_NAME ActionUnitInfantryLeaveFormation
CLASS("ActionUnitInfantryLeaveFormation", "ActionUnit")
	
	// ------------ N E W ------------
	
	/*
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
	ENDMETHOD;
	*/
	
	// logic to run when the goal is activated
	protected override METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];
		
		// We are not in formation any more
		// Reset world state property
		pr _ws = GETV(T_GETV("ai"), "worldState");
		WS_SET(_ws, WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE, false);

		// Set state
		T_SETV("state", ACTION_STATE_COMPLETED);
		
		// Return ACTIVE state
		ACTION_STATE_COMPLETED
	ENDMETHOD;
	
	// logic to run each update-step
	public override METHOD(process)
		params [P_THISOBJECT];
		
		pr _state = T_CALLM0("activateIfInactive");
		
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
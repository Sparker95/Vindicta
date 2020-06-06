#include "common.hpp"

/*
Class: ActionGroup.ActionGroupNothing
Every unit in the group will receive a GoalUnitNothing goal.
*/

#define pr private

#define OOP_CLASS_NAME ActionGroupNothing
CLASS("ActionGroupNothing", "ActionGroup")
	
	// ------------ N E W ------------

	// logic to run when the goal is activated
	protected override METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];
		
		// Set behaviour
		T_CALLM2("applyGroupBehaviour", "COLUMN", "AWARE");
		T_CALLM0("clearWaypoints");
		T_CALLM0("regroup");
		
		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);
		
		// Add goals to units
		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");
		pr _units = CALLM0(_group, "getUnits");
		{
			pr _unitAI = CALLM0(_x, "getAI");
			CALLM4(_unitAI, "addExternalGoal", "GoalUnitNothing", 0, [[TAG_INSTANT ARG _instant]], _AI);
		} forEach _units;
		
		// Return ACTIVE state
		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
	ENDMETHOD;
	
	// logic to run each update-step
	public override METHOD(process)
		params [P_THISOBJECT];
		
		//T_CALLM0("failIfEmpty");
		
		pr _state = T_CALLM0("activateIfInactive");

		if (_state == ACTION_STATE_ACTIVE) then {
			pr _group = T_GETV("group");
			pr _units = CALLM0(_group, "getUnits");
			pr _AI = T_GETV("AI");
			if (CALLSM3("AI_GOAP", "allAgentsCompletedExternalGoal", _units, "GoalUnitNothing", _AI)) then {
				_state = ACTION_STATE_COMPLETED;
			};
		};
		
		// Return the current state
		T_SETV("state", _state);
		_state
	ENDMETHOD;

ENDCLASS;
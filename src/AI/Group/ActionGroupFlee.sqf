#include "common.hpp"

/*
Class: ActionGroup.ActionGroupFlee
*/

#define OOP_CLASS_NAME ActionGroupFlee
CLASS("ActionGroupFlee", "ActionGroup")

	// logic to run when the goal is activated
	protected override METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];

		private _AI = T_GETV("AI");
		private _group = GETV(_AI, "agent");
		private _groupUnits = CALLM0(_group, "getUnits");
		{
			if (CALLM0(_x, "isInfantry")) then {
				private _unitAI = CALLM0(_x, "getAI");
				CALLM4(_unitAI, "addExternalGoal", "GoalUnitFlee", 0, [[TAG_INSTANT ARG _instant]], _AI);
			};
		} forEach _groupUnits;

		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);

		// Return ACTIVE state
		ACTION_STATE_ACTIVE
	ENDMETHOD;

	// Logic to run each update-step
	public override METHOD(process)
		params [P_THISOBJECT];
		T_CALLM0("activateIfInactive");

		ACTION_STATE_COMPLETED
	ENDMETHOD;

	public override METHOD(terminate)
		params [P_THISOBJECT];
		T_CALLCM0("ActionGroup", "terminate");
	ENDMETHOD;

ENDCLASS;

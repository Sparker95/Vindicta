#include "common.hpp"

/*
Class: ActionGroup.ActionGroupSurrender
*/

CLASS("ActionGroupSurrender", "ActionGroup")

	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];

		private _AI = T_GETV("AI");
		private _group = GETV(_AI, "agent");
		private _groupUnits = CALLM0(_group, "getUnits");

		{
			if (CALLM0(_x, "isInfantry")) then {
				private _unitAI = CALLM0(_x, "getAI");
				CALLM4(_unitAI, "addExternalGoal", "GoalUnitSurrender", 0, [], _AI);
			};
		} forEach _groupUnits;

		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);

		// Return ACTIVE state
		ACTION_STATE_ACTIVE
	} ENDMETHOD;

	// Logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		CALLM(_thisObject, "activateIfInactive", []);

		ACTION_STATE_COMPLETED
	} ENDMETHOD;

ENDCLASS;

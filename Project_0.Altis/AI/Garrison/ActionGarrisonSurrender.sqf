#include "common.hpp"

/*
Class: ActionGarrison.ActionGarrisonSurrender
*/

CLASS("ActionGarrisonSurrender", "ActionGarrison")

	METHOD("activate") {
		params [["_thisObject", "", [""]]];

		private _AI = T_GETV("AI");
		private _gar = T_GETV("gar");

		// Send surrender goal to group for more relevance
		private _groups = CALLM0(_gar, "getGroups");
		{
			private _groupAI = CALLM0(_x, "getAI");
			CALLM4(_groupAI, "addExternalGoal", "GoalGroupSurrend", 0, [], gAICommanderEast);
		} forEach _groups;

		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);

		// Return ACTIVE state
		ACTION_STATE_ACTIVE
	} ENDMETHOD;

	METHOD("process") {
		params [["_thisObject", "", [""]]];
		CALLM(_thisObject, "activateIfInactive", []);

		ACTION_STATE_COMPLETED
	} ENDMETHOD;

ENDCLASS;

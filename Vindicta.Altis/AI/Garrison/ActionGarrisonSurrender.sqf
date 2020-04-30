#include "common.hpp"

/*
Class: ActionGarrison.ActionGarrisonSurrender
*/

#define pr private

#define OOP_CLASS_NAME ActionGarrisonSurrender
CLASS("ActionGarrisonSurrender", "ActionGarrison")

	METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];

		private _AI = T_GETV("AI");
		private _gar = T_GETV("gar");

		// Send surrender goal to group for more relevance
		private _groups = CALLM0(_gar, "getGroups");
		{
			private _groupAI = CALLM0(_x, "getAI");
			private _params = [[TAG_INSTANT, _instant]];
			pr _args = ["GoalGroupSurrender", 0, _params, gAICommanderEast, false];
			CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);
		} forEach _groups;

		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);

		// Return ACTIVE state
		ACTION_STATE_ACTIVE
	ENDMETHOD;

	METHOD(process)
		params [P_THISOBJECT];

		// Bail if not spawned
		pr _gar = T_GETV("gar");
		if (!CALLM0(_gar, "isSpawned")) exitWith {T_GETV("state")};

		T_CALLM0("activateIfInactive");

		ACTION_STATE_COMPLETED
	ENDMETHOD;

ENDCLASS;

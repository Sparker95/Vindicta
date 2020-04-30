#include "common.hpp"

/*
Class: ActionGroup.ActionGroupRegroup
The whole group regroups around squad leader, units dismount their vehicles.
*/

#define OOP_CLASS_NAME ActionGroupRegroup
CLASS("ActionGroupRegroup", "ActionGroup")
	
	//VARIABLE("combatMode");

	// ------------ N E W ------------
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
		//private _combatMode = CALLSM3("Action", "getParameterValue", _parameters, TAG_COMBAT_MODE, "GREEN");
		//T_SETV("combatMode", _combatMode);

	ENDMETHOD;

	// logic to run when the goal is activated
	METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];

		// Set behaviour
		T_CALLM0("applyGroupBehaviour");
		T_CALLM0("regroup");

		// Add goals to units
		private _AI = T_GETV("AI");
		private _group = GETV(_AI, "agent");
		private _inf = CALLM0(_group, "getInfantryUnits");

		{
			private _unitAI = CALLM0(_x, "getAI");
			CALLM4(_unitAI, "addExternalGoal", "GoalUnitInfantryRegroup", 0, [[TAG_INSTANT ARG _instant]], _AI);
		} forEach _inf;

		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);

		// Return ACTIVE state
		ACTION_STATE_ACTIVE

	ENDMETHOD;
	
	// logic to run each update-step
	METHOD(process)
		params [P_THISOBJECT];
		
		T_CALLM0("failIfEmpty");

		private _AI = T_GETV("AI");
		private _group = GETV(_AI, "agent");
		private _inf = CALLM0(_group, "getInfantryUnits");

		switch true do {
			case (CALLSM3("AI_GOAP", "anyAgentFailedExternalGoal", _inf, "GoalUnitInfantryRegroup", _AI)): {
				ACTION_STATE_FAILED;
			};
			case (CALLSM3("AI_GOAP", "allAgentsCompletedExternalGoalRequired", _inf, "GoalUnitInfantryRegroup", _AI)): {
				ACTION_STATE_COMPLETED;
			};
			default {
				T_CALLM0("activateIfInactive")
			};
		};

	ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD(terminate)
		params [P_THISOBJECT];
		
		// Delete given goals
		private _AI = T_GETV("AI");
		private _group = GETV(_AI, "agent");
		private _inf = CALLM0(_group, "getInfantryUnits");
		{
			private _unitAI = CALLM0(_x, "getAI");
			CALLM2(_unitAI, "deleteExternalGoal", "GoalUnitInfantryRegroup", "");
		} forEach _inf;
		
	ENDMETHOD;

ENDCLASS;
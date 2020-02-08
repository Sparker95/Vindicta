#include "common.hpp"

/*
Class: ActionGroup.ActionGroupAAD
Some units in the group will receive a GoalUnitAAD goal.

Author: Marvis 06.02.2020
*/

#define pr private

CLASS("ActionGroupAAD", "ActionGroup")
	
	// ------------ N E W ------------

	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];		
		
		// Set state
		SETV(_thisObject, "state", ACTION_STATE_ACTIVE);
		
		// Add goals to units
		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");
		pr _units = CALLM0(_group, "getUnits");

		if (count _units >= 1) then {
			{
				pr _unitAI = CALLM0(_x, "getAI");
				CALLM4(_unitAI, "addExternalGoal", "GoalUnitAAD", 0, [], _AI);
			} forEach _units;
		};
		
		// Return ACTIVE state
		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		//CALLM0(_thisObject, "failIfEmpty");
		
		pr _state = CALLM0(_thisObject, "activateIfInactive");

		if (_state == ACTION_STATE_ACTIVE) then {
			pr _group = T_GETV("group");
			pr _units = CALLM0(_group, "getUnits");
			pr _AI = T_GETV("AI");
			if (CALLSM3("AI_GOAP", "allAgentsCompletedExternalGoal", _units, "GoalUnitAAD", _AI)) then {
				_state = ACTION_STATE_COMPLETED;
			};
		};
		
		// Return the current state
		T_SETV("state", _state);
		_state
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		// Delete given goals
		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");
		pr _units = CALLM0(_group, "getUnits");
		{
			pr _unitAI = CALLM0(_x, "getAI");
			CALLM2(_unitAI, "deleteExternalGoal", "GoalUnitAAD", "");
		} forEach _units;
		
	} ENDMETHOD;

ENDCLASS;
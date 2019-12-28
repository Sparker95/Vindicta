#include "common.hpp"

/*
Class: ActionGroup.ActionGroupRegroup
The whole group regroups around squad leader, units dismount their vehicles.
*/

#define pr private

#define THIS_ACTION_NAME "MyAction"

CLASS("ActionGroupRegroup", "ActionGroup")
	
	VARIABLE("combatMode");

	// ------------ N E W ------------
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];
		
		pr _combatMode = CALLSM3("Action", "getParameterValue", _parameters, "combatMode", false);
		if (isNil "_combatMode") then {
			_combatMode = "GREEN";
		};

		T_SETV("combatMode", _combatMode);

	} ENDMETHOD;

	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];		
		
		// Set behaviour
		pr _hG = GETV(_thisObject, "hG");
		_hG setBehaviour "AWARE";
		_hG setSpeedMode "NORMAL";
		{_x doFollow (leader _hG)} forEach (units _hG);
		
		// Set state
		SETV(_thisObject, "state", ACTION_STATE_ACTIVE);
		
		// Add goals to units
		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");
		pr _inf = CALLM0(_group, "getInfantryUnits");
		{
			pr _unitAI = CALLM0(_x, "getAI");
			CALLM4(_unitAI, "addExternalGoal", "GoalUnitInfantryRegroup", 0, [], _AI);
		} forEach _inf;
		
		// Set group combat mode
		pr _hG = T_GETV("hG");
		pr _combatMode = T_GETV("combatMode");
		_hG setCombatMode _combatMode; // Hold fire, disengage.
		OOP_INFO_1("Setting combat mode: %1", _combatMode);

		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		CALLM0(_thisObject, "failIfEmpty");
		
		CALLM0(_thisObject, "activateIfInactive");
		
		// This action is terminal because it's never over right now
		
		// Return the current state
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		// Delete given goals
		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");
		pr _inf = CALLM0(_group, "getInfantryUnits");
		{
			pr _unitAI = CALLM0(_x, "getAI");
			CALLM2(_unitAI, "deleteExternalGoal", "GoalUnitInfantryRegroup", "");
		} forEach _inf;
		
	} ENDMETHOD;

ENDCLASS;
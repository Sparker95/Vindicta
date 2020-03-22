#include "common.hpp"

/*
Class: ActionGroup.ActionGroupRegroup
The whole group regroups around squad leader, units dismount their vehicles.
*/

#define THIS_ACTION_NAME "MyAction"

CLASS("ActionGroupRegroup", "ActionGroup")
	
	//VARIABLE("combatMode");

	// ------------ N E W ------------
	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
		//private _combatMode = CALLSM3("Action", "getParameterValue", _parameters, TAG_COMBAT_MODE, "GREEN");
		//T_SETV("combatMode", _combatMode);

	} ENDMETHOD;

	// logic to run when the goal is activated
	METHOD("activate") {
		params [P_THISOBJECT];
		
		// Set behaviour
		//private _hG = GETV(_thisObject, "hG");
		//_hG setBehaviour "AWARE";
		//_hG setSpeedMode "NORMAL";
		//{_x doFollow (leader _hG)} forEach (units _hG);
		T_CALLM0("applyGroupBehaviour");
		T_CALLM0("regroup");

		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);
		
		// Add goals to units
		private _AI = T_GETV("AI");
		private _group = GETV(_AI, "agent");
		private _inf = CALLM0(_group, "getInfantryUnits");
		{
			private _unitAI = CALLM0(_x, "getAI");
			CALLM4(_unitAI, "addExternalGoal", "GoalUnitInfantryRegroup", 0, [], _AI);
		} forEach _inf;
		
		// Set group combat mode
		//private _hG = T_GETV("hG");
		//private _combatMode = T_GETV("combatMode");
		//_hG setCombatMode _combatMode;
		//OOP_INFO_1("Setting combat mode: %1", _combatMode);

		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [P_THISOBJECT];
		
		T_CALLM0("failIfEmpty");
		
		T_CALLM0("activateIfInactive");
		
		// This action is terminal because it's never over right now
		
		// Return the current state
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [P_THISOBJECT];
		
		// Delete given goals
		private _AI = T_GETV("AI");
		private _group = GETV(_AI, "agent");
		private _inf = CALLM0(_group, "getInfantryUnits");
		{
			private _unitAI = CALLM0(_x, "getAI");
			CALLM2(_unitAI, "deleteExternalGoal", "GoalUnitInfantryRegroup", "");
		} forEach _inf;
		
	} ENDMETHOD;

ENDCLASS;
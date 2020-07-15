#include "common.hpp"

/*
Class: ActionGroup.ActionGroupArrest
Tell group to arrest a suspicious player unit.
*/

#define pr private

#define OOP_CLASS_NAME ActionGroupArrest
CLASS("ActionGroupArrest", "ActionGroup")

	VARIABLE("target");		// player being arrested
	VARIABLE("arrestingUnit");

	public override METHOD(getPossibleParameters)
		[
			[ [TAG_TARGET_ARREST, [objNull]] ],	// Required parameters
			[  ]	// Optional parameters
		]
	ENDMETHOD;
	
	// ------------ N E W ------------
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		pr _target = CALLSM2("Action", "getParameterValue", _parameters, TAG_TARGET_ARREST);
		//OOP_INFO_1("ActionGroupArrest: Target: %1", _target);

		T_SETV("target", _target);
		T_SETV("arrestingUnit", NULL_OBJECT);

	ENDMETHOD;

	// logic to run when the goal is activated
	protected override METHOD(activate)
		params [P_THISOBJECT];
		
		//OOP_INFO_0("ActionGroupArrest: Activated.");
		pr _target = T_GETV("target");
		//OOP_INFO_1("ActionGroupArrest: Activated: Target: %1", _target);

		T_SETV("state", ACTION_STATE_ACTIVE);

		// Set behaviour
		T_CALLM4("applyGroupBehaviour", "FILE", "AWARE", "RED", "FULL");
		T_CALLM0("clearWaypoints");
		T_CALLM0("regroup");

		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");
		pr _groupUnits = CALLM0(_group, "getInfantryUnits");

		if(T_CALLM0("failIfNoInfantry") == ACTION_STATE_FAILED) exitWith {
			ACTION_STATE_FAILED;
		};

		pr _arrestingUnit = CALLM0(_group, "getLeader");

		// we only want one unit from the group to arrest the target
		T_SETV("arrestingUnit", _arrestingUnit);
		pr _unitai = CALLM0(_arrestingUnit, "getAI");
		pr _parameters = [[TAG_TARGET_ARREST, _target]];
		CALLM4(_unitai, "addExternalGoal", "GoalUnitArrest", 0, _parameters, _AI);

		// Else from the group will regroup
		{
			private _unitAI = CALLM0(_x, "getAI");
			CALLM4(_unitAI, "addExternalGoal", "GoalUnitInfantryRegroup", 0, [], _AI);
		} forEach (_groupUnits - [_arrestingUnits]);

		// Return ACTIVE state
		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE;
		
	ENDMETHOD;
	
	// logic to run each update-step
	public override METHOD(process)
		params [P_THISOBJECT];

		pr _state = T_CALLM0("activateIfInactive");

		if (_state == ACTION_STATE_ACTIVE) then {
			pr _arrestingUnit = T_GETV("arrestingUnit");
			pr _AI = T_GETV("AI");

			switch true do {
				// Fail if any unit has failed
				case (CALLSM3("AI_GOAP", "anyAgentFailedExternalGoal", [_arrestingUnit], "GoalUnitArrest", _AI)): {
					_state = ACTION_STATE_FAILED;
				};
				// Succeed if all units have completed the goal
				case (CALLSM3("AI_GOAP", "allAgentsCompletedExternalGoalRequired", [_arrestingUnit], "GoalUnitArrest", _AI)): {
					_state = ACTION_STATE_COMPLETED;
				};
			};
		};
		
		// Return the current state
		T_SETV("state", _state);
		_state
	ENDMETHOD;

	// Handle unit being killed/removed from group during action
	public override METHOD(handleUnitsRemoved)
		params [P_THISOBJECT, P_ARRAY("_units")];
		T_SETV("state", ACTION_STATE_FAILED);
	ENDMETHOD;

	public override METHOD(handleUnitsAdded)
		params [P_THISOBJECT, P_ARRAY("_units")];
		T_SETV("state", ACTION_STATE_REPLAN);
	ENDMETHOD;

ENDCLASS;
#include "common.hpp"

/*
Class: ActionGroup.ActionGroupArrest
Tell group to arrest a suspicious player unit.
*/

#define pr private

#define OOP_CLASS_NAME ActionGroupArrest
CLASS("ActionGroupArrest", "ActionGroup")

	VARIABLE("target");		// player being arrested
	VARIABLE("unit");		// unit arresting player
	VARIABLE("unitGoal");
	VARIABLE("arrestingUnit");
	
	// ------------ N E W ------------
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		pr _target = CALLSM2("Action", "getParameterValue", _parameters, TAG_TARGET);
		//OOP_INFO_1("ActionGroupArrest: Target: %1", _target);

		T_SETV("target", _target);
		T_SETV("unitGoal", "");
		T_SETV("arrestingUnit", NULL_OBJECT);

	ENDMETHOD;

	// logic to run when the goal is activated
	METHOD(activate)
		params [P_THISOBJECT];
		
		//OOP_INFO_0("ActionGroupArrest: Activated.");
		pr _target = T_GETV("target");
		//OOP_INFO_1("ActionGroupArrest: Activated: Target: %1", _target);

		T_SETV("state", ACTION_STATE_ACTIVE);

		// Set behaviour
		T_CALLM4("applyGroupBehaviour", "FILE", "AWARE", "RED", "NORMAL");
		T_CALLM0("clearWaypoints");
		T_CALLM0("regroup");

		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");
		pr _groupUnits = CALLM0(_group, "getInfantryUnits");

		if(count _groupUnits == 0) exitWith {
			// Can't perform arrests with no infantry
			T_SETV("state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED
		};

		pr _leader = CALLM0(_group, "getLeader");
		pr _arrestingUnit = objNull;
		pr _assistingUnits = [];
		if(count _groupUnits <= 3) then {
			_arrestingUnit = _leader;
			_assistingUnits = _groupUnits - [_arrestingUnit];
		} else {
			// exclude leader in a large group
			pr _usableUnits = _groupUnits - [_leader];
			_arrestingUnit = selectRandom _usableUnits;
			_usableUnits = _usableUnits - [_arrestingUnit];
			for "_i" from 0 to 1 do {
				_assistingUnits pushBack selectRandom (_usableUnits - _assistingUnits);
			};
		};
		pr _remainingUnits = _groupUnits - ([_arrestingUnit] + _assistingUnits);

		//// we only want one unit from the group to arrest the target
		//pr _unit = selectRandom _groupUnits;
		//OOP_INFO_1("ActionGroupArrest: groupUnits: %1", _groupUnits);
		T_SETV("arrestingUnit", _arrestingUnit);

		pr _arrestingUnitAI = CALLM0(_arrestingUnit, "getAI");
		pr _parameters = [[TAG_TARGET, _target]];

		// randomly try to shoot the leg
		pr _unitGoal = if (random 10 <= 2) then {
			"GoalUnitShootLegTarget"
		} else {
			"GoalUnitArrest"
		};
		CALLM4(_arrestingUnitAI, "addExternalGoal", _unitGoal, 0, _parameters, _AI);
		T_SETV("unitGoal", _unitGoal);

		pr _arrestingUnitHandle = CALLM0(_arrestingUnit, "getObjectHandle");
		{
			_x commandFollow _arrestingUnitHandle;
		} forEach (_assistingUnits apply { CALLM0(_x, "getObjectHandle") });

		{
			commandStop _x;
		} forEach (_remainingUnits apply { CALLM0(_x, "getObjectHandle") });

		//OOP_INFO_1("ActionGroupArrest: unit performing arrest: %1", _unit);

		// Return ACTIVE state
		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
		
	ENDMETHOD;
	
	// logic to run each update-step
	METHOD(process)
		params [P_THISOBJECT];

		pr _state = T_CALLM0("activateIfInactive");

		if (_state == ACTION_STATE_ACTIVE) then {
			pr _arrestingUnit = T_GETV("arrestingUnit");
			pr _AI = T_GETV("AI");
			pr _unitGoal = T_GETV("unitGoal");

			switch true do {
				// Fail if any unit has failed
				case (CALLSM3("AI_GOAP", "anyAgentFailedExternalGoal", [_arrestingUnit], _unitGoal, _AI)): {
					_state = ACTION_STATE_FAILED
				};
				// Succeed if all units have completed the goal
				case (CALLSM3("AI_GOAP", "allAgentsCompletedExternalGoalRequired", [_arrestingUnit], _unitGoal, _AI)): {
					_state = ACTION_STATE_COMPLETED
				};
			};
		};
		
		// Return the current state
		T_SETV("state", _state);
		_state
	ENDMETHOD;

	// Handle unit being killed/removed from group during action
	METHOD(handleUnitsRemoved)
		params [P_THISOBJECT, P_ARRAY("_units")];
		T_SETV("state", ACTION_STATE_FAILED);
	ENDMETHOD;

	METHOD(handleUnitsAdded)
		params [P_THISOBJECT, P_ARRAY("_units")];
		T_SETV("state", ACTION_STATE_REPLAN);
	ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD(terminate)
		params [P_THISOBJECT];

		//OOP_INFO_0("ActionGroupArrest: Terminating.");
		
		// Delete given goals
		pr _arrestingUnit = T_GETV("arrestingUnit");
		if(_arrestingUnit != NULL_OBJECT) then {
			pr _AI = T_GETV("AI");
			pr _unitGoal = T_GETV("unitGoal");
			pr _unitAI = CALLM0(_arrestingUnit, "getAI");
			CALLM2(_unitAI, "deleteExternalGoal", _unitGoal, _AI);

			T_CALLM0("regroup");
		};
	ENDMETHOD;

ENDCLASS;
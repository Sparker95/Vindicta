#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#define OOP_DEBUG
#define OFSTREAM_FILE "ArrestAction.rpt"
#include "common.hpp"

/*
Class: ActionGroup.ActionGroupArrest
Tell group to arrest a suspicious player unit.
*/

#define pr private

CLASS("ActionGroupArrest", "ActionGroup")

	VARIABLE("target");		// player being arrested
	VARIABLE("unit");		// unit arresting player
	
	// ------------ N E W ------------
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];

		pr _target = CALLSM2("Action", "getParameterValue", _parameters, "target");
		//OOP_INFO_1("ActionGroupArrest: Target: %1", _target);

		T_SETV("target", _target);

	} ENDMETHOD;

	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];
		
		//OOP_INFO_0("ActionGroupArrest: Activated.");
		pr _target = T_GETV("target");
		//OOP_INFO_1("ActionGroupArrest: Activated: Target: %1", _target);

		SETV(_thisObject, "state", ACTION_STATE_ACTIVE);

		// Set behaviour
		pr _hG = T_GETV("hG");
		_hG setBehaviour "AWARE";
		_hG setSpeedMode "NORMAL";
		{_x doFollow (leader _hG)} forEach (units _hG);

		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");
		pr _groupUnits = CALLM0(_group, "getUnits");
				
		// we only want one unit from the group to arrest the target
		pr _unit = selectRandom _groupUnits;
		//OOP_INFO_1("ActionGroupArrest: groupUnits: %1", _groupUnits);

		if(isNil "_unit") then {
			// Return FAILED state
			T_SETV("state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED
		} else {
			pr _unitAI = CALLM0(_unit, "getAI");
			pr _parameters = [["target", _target]];

			// randomly try to shoot the leg
			if (random 10 <= 2) then {
				CALLM4(_unitAI, "addExternalGoal", "GoalUnitShootLegTarget", 0, _parameters, _AI);
			} else {
				CALLM4(_unitAI, "addExternalGoal", "GoalUnitArrest", 0, _parameters, _AI);
			};

			//OOP_INFO_1("ActionGroupArrest: unit performing arrest: %1", _unit);

			// Return ACTIVE state
			T_SETV("state", ACTION_STATE_ACTIVE);
			ACTION_STATE_ACTIVE
		};
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];

		//OOP_INFO_0("ActionGroupArrest: Processing.");

		pr _state = CALLM0(_thisObject, "activateIfInactive");

		if (_state == ACTION_STATE_ACTIVE) then {
			pr _group = T_GETV("group");
			pr _units = CALLM0(_group, "getUnits");
			pr _AI = T_GETV("AI");
			pr _isOneSuccess = 0;

			{
				pr _unitAI = CALLM0(_x, "getAI");
				pr _goalUnitArrestState = CALLM2(_unitAI, "getExternalGoalActionState", "GoalUnitArrest", "");
				pr _goalUnitShootState = CALLM2(_unitAI, "getExternalGoalActionState", "GoalUnitShootLegTarget", "");
				if (_goalUnitArrestState == ACTION_STATE_COMPLETED || _goalUnitShootState == ACTION_STATE_COMPLETED) exitWith {
					_isOneSuccess = 1;
				};
			} forEach _units;

			if (1 == _isOneSuccess) then {
				_state = ACTION_STATE_COMPLETED;
				//OOP_INFO_0("ActionGroupArrest: Completed.");
			};
		};
		
		// Return the current state
		T_SETV("state", _state);
		//OOP_INFO_1("ActionGroupArrest: State: %1", _state);
		_state
	} ENDMETHOD;

	// Handle unit being killed/removed from group during action
	METHOD("handleUnitsRemoved") {
		params [["_thisObject", "", [""]], ["_units", [], [[]]]];
		T_SETV("state", ACTION_STATE_FAILED);
	} ENDMETHOD;

	METHOD("handleUnitsAdded") {
		params [["_thisObject", "", [""]], ["_units", [], [[]]]];
		T_SETV("state", ACTION_STATE_REPLAN);
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];

		//OOP_INFO_0("ActionGroupArrest: Terminating.");
		
		// Delete given goals
		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");
		pr _units = CALLM0(_group, "getUnits");
		{
			pr _unitAI = CALLM0(_x, "getAI");
			pr _currentGoal = GETV(_unitAI, "currentGoal");

			// check because if not it creates *massive* thousands of lines type rpt spam
			if (_currentGoal == "GoalUnitArrest") then {
				CALLM2(_unitAI, "deleteExternalGoal", "GoalUnitArrest", "");
			};

			if (_currentGoal == "GoalUnitShootLegTarget") then {
				CALLM2(_unitAI, "deleteExternalGoal", "GoalUnitShootLegTarget", "");

			};
		} forEach _units;
		
	} ENDMETHOD;

ENDCLASS;
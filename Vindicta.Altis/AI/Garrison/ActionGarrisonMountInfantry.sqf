#include "common.hpp"
/*
All infantry mounts vehicles as passengers
*/

#define pr private

#define OOP_CLASS_NAME ActionGarrisonMountInfantry
CLASS("ActionGarrisonMountInfantry", "ActionGarrison")
	VARIABLE("mount");

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		pr _mount = CALLSM2("Action", "getParameterValue", _parameters, TAG_MOUNT);
		T_SETV("mount", _mount);
	ENDMETHOD;

	// logic to run when the goal is activated
	/* private override */METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];

		pr _AI = T_GETV("AI");
		pr _gar = T_GETV("gar");

		// Find all non-vehicle groups
		pr _infGroups = CALLM1(_gar, "findGroupsByType", GROUP_TYPE_INF);

		// Do we need to mount or dismount?
		pr _goalClassName = ["GoalGroupRegroup", "GoalGroupGetInGarrisonVehiclesAsCargo"] select T_GETV("mount");
		pr _args = [_goalClassName, 0, [[TAG_INSTANT, _instant]], _AI];

		// Give goals to these groups
		{
			pr _groupAI = CALLM0(_x, "getAI");
			CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);
		} forEach _infGroups;

		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);

		// Return ACTIVE state
		ACTION_STATE_ACTIVE
	ENDMETHOD;

	// logic to run each update-step
	/* public override */ METHOD(process)
		params [P_THISOBJECT];
		
		pr _gar = T_GETV("gar");
		pr _AI = T_GETV("AI");

		if (!CALLM0(_gar, "isSpawned")) then {
			// Make sure the WSP is updated
			CALLM0(GETV(_AI, "sensorState"), "update");

			T_SETV("state", ACTION_STATE_COMPLETED);
			ACTION_STATE_COMPLETED
		} else {
			pr _state = T_CALLM0("activateIfInactive");

			if (_state == ACTION_STATE_ACTIVE) then {
				pr _gar = T_GETV("gar");
				pr _infGroups = CALLM1(_gar, "findGroupsByType", GROUP_TYPE_INF);

				// This action is completed when all infantry groups have mounted
				// Did we need to mount or dismount?
				pr _goalClassName = ["GoalGroupRegroup", "GoalGroupGetInGarrisonVehiclesAsCargo"] select T_GETV("mount");

				if (CALLSM3("AI_GOAP", "allAgentsCompletedExternalGoalRequired", _infGroups, _goalClassName, _AI)) then {
					// Make sure the WSP is updated
					CALLM0(GETV(_AI, "sensorState"), "update");
					_state = ACTION_STATE_COMPLETED;
				};
				if (CALLSM3("AI_GOAP", "anyAgentFailedExternalGoal", _infGroups, _goalClassName, _AI)) then {
					_state = ACTION_STATE_FAILED
				};
			};

			// Return the current state
			T_SETV("state", _state);
			_state
		};
	ENDMETHOD;

ENDCLASS;
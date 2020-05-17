#include "common.hpp"
/*
All crew of vehicles mounts assigned vehicles.
*/

#define pr private

#define OOP_CLASS_NAME ActionGarrisonMountCrew
CLASS("ActionGarrisonMountCrew", "ActionGarrison")
	
	VARIABLE("mount"); // Bool, true for mounting, false for dismounting
	
	// ------------ N E W ------------
	
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
		pr _mount = CALLSM2("Action", "getParameterValue", _parameters, TAG_MOUNT);
		T_SETV("mount", _mount);
	ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];
		
		pr _gar = T_GETV("gar");
		pr _AI = T_GETV("AI");
		pr _mount = T_GETV("mount");
		
		pr _vehGroups = CALLM1(_gar, "findGroupsByType", [GROUP_TYPE_VEH ARG GROUP_TYPE_STATIC]);
		
		// Do we need to mount or dismount?
		pr _goalClassName = ["GoalGroupRegroup", "GoalGroupGetInVehiclesAsCrew"] select T_GETV("mount");
		pr _args = [_goalClassName, 0, [[TAG_INSTANT, _instant]], _AI];

		// Give goals to groups
		{
			// Give goal to mount vehicles
			pr _groupAI = CALLM0(_x, "getAI");
			CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);
		} forEach _vehGroups;
		
		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);
		
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	ENDMETHOD;
	
	// logic to run each update-step
	METHOD(process)
		params [P_THISOBJECT];
		
		// Check if spawned
		pr _gar = T_GETV("gar");
		pr _AI = T_GETV("AI");
		if (!CALLM0(_gar, "isSpawned")) then {
			// If not spawned, just set world states instantly
			pr _ws = GETV(_AI, "worldState");
			[_ws, WSP_GAR_ALL_CREW_MOUNTED, true] call ws_setPropertyValue;

			T_SETV("state", ACTION_STATE_COMPLETED);
			ACTION_STATE_COMPLETED
		} else {
			pr _state = T_CALLM0("activateIfInactive");

			if (_state == ACTION_STATE_ACTIVE) then {
				pr _vehGroups = CALLM1(_gar, "findGroupsByType", [GROUP_TYPE_VEH ARG GROUP_TYPE_STATIC]);
				
				// Do we need to mount or dismount?
				pr _goalClassName = ["GoalGroupRegroup", "GoalGroupGetInVehiclesAsCrew"] select T_GETV("mount");
				switch true do {
					// Fail if any group has failed
					case (CALLSM3("AI_GOAP", "anyAgentFailedExternalGoal", _vehGroups, _goalClassName, _AI)): {
						_state = ACTION_STATE_FAILED
					};
					// Succeed if all groups have completed the goal
					case (CALLSM3("AI_GOAP", "allAgentsCompletedExternalGoalRequired", _vehGroups, _goalClassName, _AI)): {
						// Update sensors affected by this action
						CALLM0(GETV(T_GETV("AI"), "sensorState"), "update");
						_state = ACTION_STATE_COMPLETED
					};
				};
			};
			
			T_SETV("state", _state);
			_state
		};
	ENDMETHOD;

ENDCLASS;
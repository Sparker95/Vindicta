#include "common.hpp"
/*
All crew of vehicles mounts assigned vehicles.
*/

#define pr private

#define THIS_ACTION_NAME "ActionGarrisonMountCrew"

CLASS(THIS_ACTION_NAME, "ActionGarrison")
	
	VARIABLE("mount"); // Bool, true for mounting, false for dismounting
	
	// ------------ N E W ------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];
		
		pr _mount = CALLSM2("Action", "getParameterValue", _parameters, TAG_MOUNT);
		T_SETV("mount", _mount);
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_to", "", [""]]];		
		
		pr _gar = T_GETV("gar");
		pr _AI = T_GETV("AI");
		pr _mount = T_GETV("mount");
		
		pr _vehGroups = CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_NON_STATIC) + CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_STATIC);
		
		// Do we need to mount or dismount?
		if (_mount) then {
			{
				// Give goal to mount vehicles
				pr _groupAI = CALLM0(_x, "getAI");
				pr _args = ["GoalGroupGetInVehiclesAsCrew", 0, [], _AI];
				CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);
			} forEach _vehGroups;
		} else {
			// NYI
		};
		
		// Set state
		SETV(_thisObject, "state", ACTION_STATE_ACTIVE);
		
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		pr _state = CALLM0(_thisObject, "activateIfInactive");
		
		scopeName "s0";
		
		if (_state == ACTION_STATE_ACTIVE) then {
			pr _gar = T_GETV("gar");
			pr _AI = T_GETV("AI");
			pr _mount = T_GETV("mount");
			pr _vehGroups = CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_NON_STATIC) + CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_STATIC);
			
			// Do we need to mount or dismount?
			if (_mount) then {
				// Fail this action if any group has failed
				if (CALLSM3("AI_GOAP", "anyAgentFailedExternalGoal", _vehGroups, "GoalGroupGetInVehiclesAsCrew", _AI)) then {
					_state = ACTION_STATE_FAILED;
					breakTo "s0";
				};
				
				// Complete the action when all vehicle groups have mounted
				if (CALLSM3("AI_GOAP", "allAgentsCompletedExternalGoal", _vehGroups, "GoalGroupGetInVehiclesAsCrew", _AI)) then {
				//pr _ws = GETV(T_GETV("AI"), "worldState");
				//if ([_ws, WSP_GAR_ALL_CREW_MOUNTED] call ws_getPropertyValue) then {			
					// Update sensors affected by this action
					CALLM0(GETV(T_GETV("AI"), "sensorHealth"), "update");
					
					_state = ACTION_STATE_COMPLETED;
					breakTo "s0";
				};
			} else {
				// NYI
			};
		};
		
		T_SETV("state", _state);
		_state
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		pr _gar = T_GETV("gar");
		pr _mount = T_GETV("mount");
		pr _args = [GROUP_TYPE_VEH_NON_STATIC, GROUP_TYPE_VEH_STATIC];
		pr _vehGroups = CALLM1(_gar, "findGroupsByType", _args);

		// Did we need to mount or dismount?
		if (_mount) then {
			{
				// Delete goal to mount vehicles
				pr _groupAI = CALLM0(_x, "getAI");
				pr _args = ["GoalGroupGetInVehiclesAsCrew", ""];
				CALLM2(_groupAI, "postMethodAsync", "deleteExternalGoal", _args);
			} forEach _vehGroups;
		} else {
			// NYI
		};
		
	} ENDMETHOD; 

ENDCLASS;
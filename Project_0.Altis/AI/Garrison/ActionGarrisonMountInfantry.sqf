#include "common.hpp"
/*
All infantry mounts vehicles as passengers
*/

#define pr private

#define THIS_ACTION_NAME "ActionGarrisonMountInfantry"

CLASS(THIS_ACTION_NAME, "ActionGarrison")

	// ------------ N E W ------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]] ];
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_to", "", [""]]];		
		
		pr _AI = T_GETV("AI");
		pr _gar = T_GETV("gar");
		
		// Find all non-vehicle groups
		pr _groupTypes = [GROUP_TYPE_IDLE, GROUP_TYPE_BUILDING_SENTRY, GROUP_TYPE_PATROL];
		pr _infGroups = CALLM1(_gar, "findGroupsByType", _groupTypes);
		
		// Give goals to these groups
		{
			pr _groupAI = CALLM0(_x, "getAI");
			pr _args = ["GoalGroupGetInGarrisonVehiclesAsCargo", 0, [], _AI];
			CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);
		} forEach _infGroups;
		
		// Set state
		SETV(_thisObject, "state", ACTION_STATE_ACTIVE);
		
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		pr _state = CALLM0(_thisObject, "activateIfInactive");
		
		if (_state == ACTION_STATE_ACTIVE) then {
			pr _gar = T_GETV("gar");
			pr _groupTypes = [GROUP_TYPE_IDLE, GROUP_TYPE_BUILDING_SENTRY, GROUP_TYPE_PATROL];
			pr _infGroups = CALLM1(_gar, "findGroupsByType", _groupTypes);
			
			// This action is completed when all infantry groups have mounted
			
			if (CALLSM3("AI_GOAP", "allAgentsCompletedExternalGoal", _infGroups, "GoalGroupGetInGarrisonVehiclesAsCargo", "")) then {
				 //Update sensors affected by this action
				CALLM0(GETV(T_GETV("AI"), "sensorHealth"), "update");
				
			//pr _ws = GETV(T_GETV("AI"), "worldState");
			//if ([_ws, WSP_GAR_ALL_INFANTRY_MOUNTED] call ws_getPropertyValue) then {
				_state = ACTION_STATE_COMPLETED		
			};
		};
		
		// Return the current state
		T_SETV("state", _state);
		_state
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		// Delete goals given by this action
		pr _gar = T_GETV("gar");
		pr _groupTypes = [GROUP_TYPE_IDLE, GROUP_TYPE_BUILDING_SENTRY, GROUP_TYPE_PATROL];
		pr _infGroups = CALLM1(_gar, "findGroupsByType", _groupTypes);
		
		{
			pr _groupAI = CALLM0(_x, "getAI");
			pr _args = ["GoalGroupGetInGarrisonVehiclesAsCargo", ""];
			CALLM2(_groupAI, "postMethodAsync", "deleteExternalGoal", _args);
		} forEach _infGroups;
	} ENDMETHOD;

ENDCLASS;
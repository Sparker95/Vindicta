#include "common.hpp"
/*
All infantry mounts vehicles as passengers
*/

#define pr private

CLASS("ActionGarrisonMountInfantry", "ActionGarrison")

	VARIABLE("mount");

	// ------------ N E W ------------
	
	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		pr _mount = CALLSM2("Action", "getParameterValue", _parameters, TAG_MOUNT);
		T_SETV("mount", _mount);
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [P_THISOBJECT, P_BOOL("_instant")];
		
		pr _AI = T_GETV("AI");
		pr _gar = T_GETV("gar");
		
		// Find all non-vehicle groups
		pr _groupTypes = [GROUP_TYPE_IDLE, GROUP_TYPE_PATROL];
		pr _infGroups = CALLM1(_gar, "findGroupsByType", _groupTypes);
		 
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
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [P_THISOBJECT];
		
		pr _gar = T_GETV("gar");
		if (!CALLM0(_gar, "isSpawned")) then {

			pr _AI = T_GETV("AI");
			pr _ws = GETV(_AI, "worldState");
			[_ws, WSP_GAR_ALL_INFANTRY_MOUNTED, true] call ws_setPropertyValue;

			T_SETV("state", ACTION_STATE_COMPLETED);
			ACTION_STATE_COMPLETED
		} else {
			pr _state = T_CALLM0("activateIfInactive");
			
			if (_state == ACTION_STATE_ACTIVE) then {
				pr _gar = T_GETV("gar");
				pr _groupTypes = [GROUP_TYPE_IDLE, GROUP_TYPE_PATROL];
				pr _infGroups = CALLM1(_gar, "findGroupsByType", _groupTypes);
				
				// This action is completed when all infantry groups have mounted
				
				// Did we need to mount or dismount?
				pr _goalClassName = ["GoalGroupRegroup", "GoalGroupGetInGarrisonVehiclesAsCargo"] select T_GETV("mount");

				if (CALLSM3("AI_GOAP", "allAgentsCompletedExternalGoalRequired", _infGroups, _goalClassName, "")) then {
					//Update sensors affected by this action
					CALLM0(GETV(T_GETV("AI"), "sensorState"), "update");
					
					//pr _ws = GETV(T_GETV("AI"), "worldState");
					//if ([_ws, WSP_GAR_ALL_INFANTRY_MOUNTED] call ws_getPropertyValue) then {
					_state = ACTION_STATE_COMPLETED
				};
			};
			
			// Return the current state
			T_SETV("state", _state);
			_state
		};
	} ENDMETHOD;
	
	// // logic to run when the action is satisfied
	// METHOD("terminate") {
	// 	params [P_THISOBJECT];
		
	// 	// Bail if not spawned
	// 	pr _gar = T_GETV("gar");
	// 	if (!CALLM0(_gar, "isSpawned")) exitWith {};

	// 	// Delete goals given by this action
	// 	pr _gar = T_GETV("gar");
	// 	pr _groupTypes = [GROUP_TYPE_IDLE, GROUP_TYPE_PATROL];
	// 	pr _infGroups = CALLM1(_gar, "findGroupsByType", _groupTypes);
		
	// 	{
	// 		pr _groupAI = CALLM0(_x, "getAI");
	// 		pr _args = ["GoalGroupGetInGarrisonVehiclesAsCargo", ""];
	// 		CALLM2(_groupAI, "postMethodAsync", "deleteExternalGoal", _args);
	// 	} forEach _infGroups;
	// } ENDMETHOD;

	// 	// Handle units/groups added/removed

	// METHOD("handleGroupsAdded") {
	// 	params [P_THISOBJECT, P_ARRAY("_groups")];
		
	// 	T_SETV("state", ACTION_STATE_REPLAN);
	// } ENDMETHOD;

	// METHOD("handleGroupsRemoved") {
	// 	params [P_THISOBJECT, P_ARRAY("_groups")];
		
	// 	T_SETV("state", ACTION_STATE_REPLAN);
	// } ENDMETHOD;
	
	// METHOD("handleUnitsRemoved") {
	// 	params [P_THISOBJECT, P_ARRAY("_units")];
		
	// 	T_SETV("state", ACTION_STATE_REPLAN);
	// } ENDMETHOD;
	
	// METHOD("handleUnitsAdded") {
	// 	params [P_THISOBJECT, P_ARRAY("_units")];
		
	// 	T_SETV("state", ACTION_STATE_REPLAN);
	// } ENDMETHOD;

ENDCLASS;
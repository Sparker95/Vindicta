#include "common.hpp"

/*
Relax action
*/

#define pr private

#define THIS_ACTION_NAME "ActionGarrisonRelax"

CLASS(THIS_ACTION_NAME, "ActionGarrison")
	
	// ------------ N E W ------------
	/*
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]] ];
		SETV(_thisObject, "AI", _AI);
	} ENDMETHOD;
	*/
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];		
		
		OOP_INFO_0("ACTIVATE");
		
		// Give goals to groups
		pr _gar = GETV(T_GETV("AI"), "agent");
		pr _AI = T_GETV("AI");
		pr _groups = CALLM0(_gar, "getGroups");
		{ // foreach _groups
			pr _type = CALLM0(_x, "getType");
			pr _groupAI = CALLM0(_x, "getAI");
			
			if (_groupAI != "") then {
				pr _args = [];
				switch (_type) do {
					case GROUP_TYPE_IDLE: {
						_args = ["GoalGroupRelax", 0, [], _AI];
					};
					
					case GROUP_TYPE_VEH_STATIC: {
						_args = ["GoalGroupRelax", 0, [], _AI];
					};
					
					case GROUP_TYPE_VEH_NON_STATIC: {
						_args = ["GoalGroupRelax", 0, [], _AI];
					};
					
					case GROUP_TYPE_BUILDING_SENTRY: {
						_args = ["GoalGroupRelax", 0, [], _AI];
					};
					
					case GROUP_TYPE_PATROL: {
						_args = ["GoalGroupPatrol", 0, [], _AI];
					};
				};
				
				if (count _args > 0) then {
					CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);
				};
			};
		} forEach _groups;
		
		// Set state
		SETV(_thisObject, "state", ACTION_STATE_ACTIVE);
		
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		// Bail if not spawned
		pr _gar = T_GETV("gar");
		if (!CALLM0(_gar, "isSpawned")) exitWith {T_GETV("state")};

		CALLM0(_thisObject, "activateIfInactive");
		
		// Return the current state
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		// Bail if not spawned
		pr _gar = T_GETV("gar");
		if (!CALLM0(_gar, "isSpawned")) exitWith {};

		// Delete assigned patrol goals
		pr _AI = GETV(_thisObject, "AI");
		pr _gar = GETV(_AI, "agent");
		pr _patrolGroups = CALLM1(_gar, "findGroupsByType", GROUP_TYPE_PATROL);
		//ade_dumpCallstack;
		{
			pr _groupAI = CALLM0(_x, "getAI");
			if (!isNil "_groupAI") then {
				if (_groupAI != "") then {
					pr _args = ["GoalGroupPatrol", ""];
					CALLM2(_groupAI, "postMethodAsync", "deleteExternalGoal", _args);
				};
			};
		} forEach _patrolGroups;
		
		
		// Remove assigned goals
		pr _gar = GETV(T_GETV("AI"), "agent");
		pr _groups = CALLM0(_gar, "getGroups");
		{ // foreach _groups
			pr _type = CALLM0(_x, "getType");
			pr _groupAI = CALLM0(_x, "getAI");
			
			if (_groupAI != "") then {
				pr _args = [];
				switch (_type) do {
					case GROUP_TYPE_IDLE: {
						_args = ["GoalGroupRelax", ""];
					};
					
					case GROUP_TYPE_VEH_STATIC: {
						_args = ["GoalGroupRelax", ""];
					};
					
					case GROUP_TYPE_VEH_NON_STATIC: {
						_args = ["GoalGroupRelax", ""];
					};
					
					case GROUP_TYPE_BUILDING_SENTRY: {
						_args = ["GoalGroupRelax", ""];
					};
					
					case GROUP_TYPE_PATROL: {
						_args = ["GoalGroupPatrol", ""];						
					};
				};
				
				if (count _args > 0) then {
					CALLM2(_groupAI, "postMethodAsync", "deleteExternalGoal", _args);
				};
			};
		} forEach _groups;
		
	} ENDMETHOD;


	METHOD("handleGroupsAdded") {
		params [["_thisObject", "", [""]], ["_groups", [], [[]]]];
		
		T_SETV("state", ACTION_STATE_REPLAN);

		nil
	} ENDMETHOD;

ENDCLASS;
#include "common.hpp"

/*
All crew of vehicles mounts assigned vehicles.
*/

#define pr private

#define THIS_ACTION_NAME "ActionGarrisonDefendPassive"

CLASS(THIS_ACTION_NAME, "ActionGarrison")

	// ------------ N E W ------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]] ];
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];		
		
		OOP_INFO_0("ACTIVATE");
		
		// Give goals to groups
		pr _gar = GETV(T_GETV("AI"), "agent");
		pr _loc = CALLM0(_gar, "getLocation");
		pr _AI = T_GETV("AI");
		pr _groups = CALLM0(_gar, "getGroups");
		{ // foreach _groups
			pr _type = CALLM0(_x, "getType");
			pr _groupAI = CALLM0(_x, "getAI");
			
			if (_groupAI != "") then {
				pr _args = [];
				switch (_type) do {
					case GROUP_TYPE_IDLE: {
						_args = ["GoalGroupRegroup", 0, [], _AI];
					};
					
					case GROUP_TYPE_VEH_STATIC: {
						_args = ["GoalGroupGetInVehiclesAsCrew", 0, [], _AI];
					};
					
					case GROUP_TYPE_VEH_NON_STATIC: {
						_args = ["GoalGroupGetInVehiclesAsCrew", 0, [["onlyCombat", true]], _AI]; // Occupy only combat vehicles
					};
					
					case GROUP_TYPE_BUILDING_SENTRY: {
						_args = if (_loc != "") then {
							["GoalGroupOccupySentryPositions", 0, [], _AI];
						} else {
							["GoalGroupRegroup", 0, [], _AI];
						};
					};
					
					case GROUP_TYPE_PATROL: {
						_args = ["GoalGroupRegroup", 0, [], _AI];
					};
				};
				
				if (count _args > 0) then {
					CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);
					// Poke group AI to switch mode faster
					CALLM2(_groupAI, "postMethodAsync", "process", []);
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
		
		CALLM(_thisObject, "activateIfInactive", []);
		
		//diag_log "---- Garrison defend passive action!";
		
		
		
		// Return the current state
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		// Remove assigned goals
		pr _gar = GETV(T_GETV("AI"), "agent");
		pr _loc = CALLM0(_gar, "getLocation");
		pr _groups = CALLM0(_gar, "getGroups");
		{ // foreach _groups
			pr _type = CALLM0(_x, "getType");
			pr _groupAI = CALLM0(_x, "getAI");
			if (_groupAI != "") then {
				pr _args = [];
				switch (_type) do {
					case GROUP_TYPE_IDLE: {
						_args = ["GoalGroupRegroup", ""];
					};
					
					case GROUP_TYPE_VEH_STATIC: {
						_args = ["GoalGroupGetInVehiclesAsCrew", ""];
					};
					
					case GROUP_TYPE_VEH_NON_STATIC: {
						_args = ["GoalGroupGetInVehiclesAsCrew", ""];
					};
					
					case GROUP_TYPE_BUILDING_SENTRY: {
						_args = if (_loc != "") then {
							["GoalGroupOccupySentryPositions", ""];
						} else {
							["GoalGroupRegroup", ""];
						};
					};
					
					case GROUP_TYPE_PATROL: {
						_args = ["GoalGroupRegroup", ""];						
					};
				};
				
				if (count _args > 0) then {
					CALLM2(_groupAI, "postMethodAsync", "deleteExternalGoal", _args);
				};
			};
		} forEach _groups;
		
	} ENDMETHOD; 

ENDCLASS;
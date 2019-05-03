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
		params [["_thisObject", "", [""]]];		
		
		pr _gar = T_GETV("gar");
		pr _AI = T_GETV("AI");
		pr _mount = T_GETV("mount");
		
		pr _vehGroups = CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_NON_STATIC) + CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_STATIC);
		
		// Do we need to mount or dismount?
		if (_mount) then {
			pr _args = ["GoalGroupGetInVehiclesAsCrew", 0, [], _AI];
			{
				// Give goal to mount vehicles
				pr _groupAI = CALLM0(_x, "getAI");
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
		
		// Check if spawned
		pr _gar = T_GETV("gar");
		if (!CALLM0(_gar, "isSpawned")) then {
			// If not spawned, just set world states instantly
			pr _AI = T_GETV("AI");
			pr _ws = GETV(_AI, "worldState");
			[_ws, WSP_GAR_ALL_CREW_MOUNTED, true] call ws_setPropertyValue;

			T_SETV("state", ACTION_STATE_COMPLETED);
			ACTION_STATE_COMPLETED
		} else {
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
						CALLM0(GETV(T_GETV("AI"), "sensorState"), "update");
						
						_state = ACTION_STATE_COMPLETED;
						breakTo "s0";
					};
				} else {
					// NYI
				};
			};
			
			T_SETV("state", _state);
			_state
		};
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		// Bail if not spawned
		pr _gar = T_GETV("gar");
		if (!CALLM0(_gar, "isSpawned")) exitWith {};


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


	// Handle units/groups added/removed

	METHOD("handleGroupsAdded") {
		params [["_thisObject", "", [""]], ["_groups", [], [[]]]];
		
		T_SETV("state", ACTION_STATE_REPLAN);
	} ENDMETHOD;

	METHOD("handleGroupsRemoved") {
		params [["_thisObject", "", [""]], ["_groups", [], [[]]]];
		
		T_SETV("state", ACTION_STATE_REPLAN);
	} ENDMETHOD;
	
	METHOD("handleUnitsRemoved") {
		params [["_thisObject", "", [""]], ["_units", [], [[]]]];
		
		T_SETV("state", ACTION_STATE_REPLAN);
	} ENDMETHOD;
	
	METHOD("handleUnitsAdded") {
		params [["_thisObject", "", [""]], ["_units", [], [[]]]];
		
		T_SETV("state", ACTION_STATE_REPLAN);
	} ENDMETHOD;

ENDCLASS;
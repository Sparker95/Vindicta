#define OOP_INFO
#define OON_WARNING
#define OOP_ERROR
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\Action\Action.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"
#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"
#include "garrisonWorldStateProperties.hpp"
#include "..\parameterTags.hpp"
#include "..\..\Group\Group.hpp"

/*
Garrison moves on available vehicles
*/

#define pr private

#define THIS_ACTION_NAME "ActionGarrisonMoveMounted"

CLASS(THIS_ACTION_NAME, "ActionGarrison")


	VARIABLE("pos"); // The destination position

	// ------------ N E W ------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];
		
		pr _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		T_SETV("pos", _pos);
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_to", "", [""]]];		
		
		// Give waypoint to the vehicle group
		pr _gar = T_GETV("gar");
		pr _AI = T_GETV("AI");
		pr _pos = T_GETV("pos");
		
		pr _vehGroups = CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_NON_STATIC) + CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_STATIC);
		if (count _vehGroups > 1) then {
			OOP_ERROR_0("More than one vehicle group in the garrison!");
		};
		
		{
			pr _group = _x;
			pr _groupAI = CALLM0(_x, "getAI");
			
			// Add new goal to move
			pr _args = ["GoalGroupMoveGroundVehicles", 0, [[TAG_POS, _pos]], _AI];
			CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);			
			
		} forEach _vehGroups;
		
		// Set state
		SETV(_thisObject, "state", ACTION_STATE_ACTIVE);
		
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		// Fail if not everyone is in vehicles
		pr _everyoneIsMounted = CALLM0(_thisObject, "isEveryoneInVehicle");
		OOP_INFO_1("Everyone is in vehicles: %1", _everyoneIsMounted);
		if (! _everyoneIsMounted) exitWith {
			OOP_INFO_0("ACTION FAILED because not everyone is in vehicles");
			T_SETV("state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED
		};
		
		pr _state = CALLM(_thisObject, "activateIfInactive", []);
		
		scopeName "s0";
		
		if (_state == ACTION_STATE_ACTIVE) then {
		
			pr _gar = T_GETV("gar");
			pr _AI = T_GETV("AI");
			pr _pos = T_GETV("pos");
		
			// Complete if all groups' actions are completed
			pr _vehGroups = CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_NON_STATIC) + CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_STATIC);
			
			// Fail if any group has failed
			if (CALLSM3("AI", "anyAgentFailedExternalGoal", _vehGroups, "GoalGroupMoveGroundVehicles", "")) then {
				_state = ACTION_STATE_FAILED;
				breakTo "s0";
			};
			
			// Succede if all groups have completed the goal
			if (CALLSM3("AI", "allAgentsCompletedExternalGoal", _vehGroups, "GoalGroupMoveGroundVehicles", "")) then {
				_state = ACTION_STATE_COMPLETED;
				breakTo "s0";
			};
		};
		
		// Return the current state
		T_SETV("state", _state);
		_state
	} ENDMETHOD;
	
	// Returns true if everyone is in vehicles
	METHOD("isEveryoneInVehicle") {
		params ["_thisObject"];
		pr _AI = T_GETV("AI");
		pr _ws = GETV(_AI, "worldState");
		
		pr _return = 	([_ws, WSP_GAR_ALL_CREW_MOUNTED] call ws_getPropertyValue) &&
						([_ws, WSP_GAR_ALL_INFANTRY_MOUNTED] call ws_getPropertyValue);
		
		_return
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		pr _gar = T_GETV("gar");
		// Terminate given goals
		pr _vehGroups = CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_NON_STATIC) + CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_STATIC);
		{
			pr _group = _x;
			pr _groupAI = CALLM0(_x, "getAI");
			// Delete other goals like this first
			pr _args = ["GoalGroupMoveGroundVehicles", ""];
			CALLM2(_groupAI, "postMethodAsync", "deleteExternalGoal", _args);			
		} forEach _vehGroups;
		
	} ENDMETHOD;

ENDCLASS;
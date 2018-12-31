#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\Action\Action.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"
#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"
#include "..\..\Group\Group.hpp"
#include "garrisonWorldStateProperties.hpp"

/*
Relax action
*/

#define pr private

#define THIS_ACTION_NAME "ActionGarrisonRelax"

CLASS(THIS_ACTION_NAME, "Action")
	
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
		
		
		// Assign patrol goal to patrol groups
		pr _AI = GETV(_thisObject, "AI");
		pr _gar = GETV(_AI, "agent");
		pr _patrolGroups = CALLM1(_gar, "findGroupsByType", GROUP_TYPE_PATROL);
		//ade_dumpCallstack;
		{
			pr _groupAI = CALLM0(_x, "getAI");
			if (!isNil "_groupAI") then {
				if (_groupAI != "") then {
					// Give a patrol task to this group
					pr _args = ["GoalGroupPatrol", 0, [], _AI];
					CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);
				};
			};
		} forEach _patrolGroups;
		
		// Set state
		SETV(_thisObject, "state", ACTION_STATE_ACTIVE);
		
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		CALLM(_thisObject, "activateIfInactive", []);
		
		// Return the current state
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		// Delete assigned patrol goals
		pr _AI = GETV(_thisObject, "AI");
		pr _gar = GETV(_AI, "agent");
		pr _patrolGroups = CALLM1(_gar, "findGroupsByType", GROUP_TYPE_PATROL);
		//ade_dumpCallstack;
		{
			pr _groupAI = CALLM0(_x, "getAI");
			if (!isNil "_AI") then {
				if (_AI != "") then {
					pr _args = ["GoalGroupPatrol", ""];
					CALLM2(_groupAI, "postMethodAsync", "deleteExternalGoal", _args);
				};
			};
		} forEach _patrolGroups;
		
	} ENDMETHOD;

ENDCLASS;
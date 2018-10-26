/*
Parallel goal evaluates all subgoals at once.

It returns:
COMPLETED if all subgoals are in COMPLETED state
FAILED if any subgoal has failed
INACTIVE right after this goal creation
ACTIVE otherwise

Author: Sparker 05.08.2018
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Goal\Goal.hpp"

CLASS("GoalCompositeParallel", "GoalComposite")
	
	// ----------------------------------------------------------------------
	// |                            P R O C E S S                           |
	// |                                                                    |
	// | By default we just process all subgoals in parallel way            |
	// ----------------------------------------------------------------------
	
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		private _state = CALLM(_thisObject, "processSubgoals", []);
		SETV(_thisObject, "state", _state);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    P R O C E S S   S U B G O A L S                 |
	// ----------------------------------------------------------------------
	
	METHOD("processSubgoals") {
		params [["_thisObject", "", [""]]];
		private _subgoals = GETV(_thisObject, "subgoals");
		
		private _subgoalsStates = _subgoals apply { CALLM(_x, "process", []) };
		
		// Are all subgoals completed?
		private _countCompleted = {_x == GOAL_STATE_COMPLETED} count _subgoalsStates;
		if (_countCompleted == count _subgoals) exitWith { GOAL_STATE_COMPLETED };
		
		// Has any subgoal failed?
		private _countFailed = {_x == GOAL_STATE_FAILED} count _subgoalsStates;
		if (_countFailed > 0) exitWith { GOAL_STATE_FAILED };
		
		// Otherwise return ACTIVE
		GOAL_STATE_ACTIVE
	} ENDMETHOD;

ENDCLASS;
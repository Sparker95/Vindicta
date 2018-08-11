/*
The composite goal class. It is a base class for GoalCompositeSerial and GoalCompositeParallel.

Based on source from "Programming Game AI by Example" by Mat Buckland: http://www.ai-junkie.com/books/toc_pgaibe.html

Author: Sparker 05.08.2018
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Goal\Goal.hpp"

CLASS("GoalComposite", "Goal")

	VARIABLE("subgoals"); // Array with subgoals
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]]];
		SETV(_thisObject, "subgoals", []);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		
		// Delete all subgoals
		CALLM(_thisObject, "deleteAllSubgoals", []);
	} ENDMETHOD;
	
	
	// Serial and Parallel composite goals implement this method differently
	/*virtual*/ METHOD("processSubgoals") {	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                          A D D   S U B G O A L                     |
	// |                                                                    |
	// | Adds a subgoal to the front of the subgoal array                   |
	// ----------------------------------------------------------------------
	METHOD("addSubgoal") {
		params [["_thisObject", "", [""]], ["_subgoal", "", [""]] ];
		private _subgoals = GETV(_thisObject, "subgoals");
		private _newSubgoals = [_subgoal];
		_newSubgoals append _subgoals;
		SETV(_thisObject, "subgoals", _newSubgoals);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   D E L E T E   A L L   S U B G O A L S            |
	// ----------------------------------------------------------------------
	
	METHOD("deleteAllSubgoals") {
		params [["_thisObject", "", [""]]];
		// Regardless if the goal is serial or parallel, terminate and delete all subgoals
		private _subgoals = GETV(_thisObject, "subgoals");
		{
			CALLM(_x, "terminate", []);
			DELETE(_x);
		} forEach _subgoals;
		SETV(_thisObject, "subgoals", []);
	} ENDMETHOD;

ENDCLASS;
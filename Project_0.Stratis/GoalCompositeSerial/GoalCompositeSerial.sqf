/*
The composite goal class.
Based on source from "Programming Game AI by Example" by Mat Buckland: http://www.ai-junkie.com/books/toc_pgaibe.html

Author: Sparker 05.08.2018
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Goal\Goal.hpp"

CLASS("GoalCompositeSerial", "GoalComposite")

	// ----------------------------------------------------------------------
	// |                            P R O C E S S                           |
	// |                                                                    |
	// | By default we just process all subgoals                            |
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
		
		// remove all completed and failed goals from the front of the subgoal list
		while {count _subgoals > 0} do {
			private _subgoalFront = _subgoals select 0;
			private _state = GETV(_subgoalFront, "state");
			if (_state != GOAL_STATE_COMPLETED && _state != GOAL_STATE_FAILED) exitWith {};
			// The front goal is in either COMPLETED or FAILED state, so we must delete it
			CALLM(_subgoalFront, "terminate", []);
			DELETE(_subgoalFront);
			_subgoals deleteAt 0;
		};
		
		// if any subgoals remain, process the one at the front of the list
		private _statusOfSubgoals = GOAL_STATE_COMPLETED; // If there will be no subgoals to process, return COMPLETED
		if (count _subgoals > 0) then {
			private _subgoalFront = _subgoals select 0;
			
			// grab the status of the front-most subgoal
			_statusOfSubgoals = CALLM(_subgoalFront, "process", []);
			
			// we have to test for the special case where the front-most subgoal
		    // reports 'completed' *and* the subgoal list contains additional goals.When
		    // this is the case, to ensure the parent keeps processing its subgoal list
		    // we must return the 'active' status.
		    if (_statusOfSubgoals == GOAL_STATE_COMPLETED && count _subgoals > 1) then {
		    	_statusOfSubgoals = GOAL_STATE_ACTIVE;
		    };
		};
		
		// return
		_statusOfSubgoals
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                      H A N D L E   M E S S A G E                   |
	// |                                                                    |
	// | Forwards the message to frontmost subgoal
	// ----------------------------------------------------------------------
	
	METHOD("handleMessage") { //Derived classes must implement this method
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
		private _msgHandled = CALL_CLASS_METHOD("Goal", _thisObject, "handleMessage", [_msg]);
		if (!_msgHandled) then {
			private _msgHandled = CALLM(_thisObject, "forwardMessageToFrontSubgoal", [_msg]);
			_msgHandled // return
		} else {
			true // message handled
		};
	} ENDMETHOD;
	
	// -----------------------------------------------------------------------------------------------
	//                F O R W A R D   M E S S A G E   T O   F R O N T   S U B G O A L
	//
	// passes the message to the goal at the front of the queue
	// -----------------------------------------------------------------------------------------------
	
	METHOD("forwardMessageToFrontSubgoal") {
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
		private _subgoals = GETV(_thisObject, "subgoals");
		private _subgoalFront = _subgoals select 0;
		CALLM(_subgoalFront, "handleMessage", [_msg]);
	} ENDMETHOD;

ENDCLASS;
/*
A composite goal for a unit to sit on a bench.
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Goal\Goal.hpp"

CLASS("GoalUnitSitOnBench", "GoalCompositeSerial")

	VARIABLE("bench"); // Bench is derived from AnimObject
	VARIABLE("pointID"); // The ID of the point where the unit is going to sit at
	VARIABLE("sitDuration"); // How many seconds the bot will be sitting on the bench until the task is completed
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_entity", "", [""]], ["_bench", "", [""]], ["_sitDuration", 0, [0]]];
		SETV(_thisObject, "bench", _bench);
		SETV(_thisObject, "sitDuration", _sitDuration);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                        A C T I V A T E                             |
	// ----------------------------------------------------------------------

	METHOD("activate") {
		params [["_thisObject", "", [""]]];
		private _entity = GETV(_thisObject, "entity");
		private _bench = GETV(_thisObject, "bench");
		private _pointIDAndPos = CALLM(_bench, "getFreePoint", []);
		if (count _pointIDAndPos > 0) then {
			_pointIDAndPos params ["_pointID", "_pos"];
			SETV(_thisObject, "pointID", _pointID);
			
			// Add a goal to sit on the bench
			private _sitDuration = GETV(_thisObject, "sitDuration");
			private _args = [_entity, _bench, _sitDuration, _pointID];// ["_entity", "", [""]], ["_bench", [], [[]]], ["_sitDuration", 0, [0]], ["_pointID", 0, [0]]
			private _goalDoSitOnBench = NEW("GoalUnitDoSitOnBench", _args);
			CALLM(_thisObject, "addSubgoal", [_goalDoSitOnBench]);
			
			// Add a goal for the unit to move to the bench
			private _posMoveTo = [_pos select 0, _pos select 1, _pos select 2 + 1];
			private _args = [_entity, _pos];
			private _goalMove = NEW("GoalUnitMoveInf", _args);
			CALLM(_thisObject, "addSubgoal", [_goalMove]);
			
			SETV(_thisObject, "state", GOAL_STATE_ACTIVE);
		} else {
			// The bench is already occupied!
			SETV(_thisObject, "state", GOAL_STATE_FAILED);
		};		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                          P R O C E S S                             |
	// ----------------------------------------------------------------------

	METHOD("process") {
		params [["_thisObject", "", [""]]];
		CALLM(_thisObject, "activateIfInactive", []);
		
		// Check if the desired position is still free
		//private _bench = GETV(_thisObject, "bench");
		//private _pointID = GETV(_thisObject, "pointID");
		//if ( CALLM(_bench, "isPointFree", [_pointID]) ) then {
			// Process subgoals
			private _state = CALLM(_thisObject, "processSubgoals", []);
			SETV(_thisObject, "state", _state);
			
			_state // return the state
		//} else {
		//	// Make the goal inactive so that it replans itself at the next update step
		//	CALLM(_thisObject, "deleteAllSubgoals", []);
		//	SETV(_thisObject, "state", GOAL_STATE_INACTIVE)
		//	GOAL_STATE_INACTIVE
		//};
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                        T E R M I N A T E                           |
	// ----------------------------------------------------------------------

	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		private _entity = GETV(_thisObject, "entity");
		CALLM(_entity, "doStopInf");
	} ENDMETHOD;

ENDCLASS;